#!/usr/bin/env bash
#
# Gooze-CMS 工程化管理脚本 (Bash 版本)
# 兼容 Linux / macOS (OSX)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
API_DIR="${PROJECT_ROOT}/gooze-vben-api"
ADMIN_DIR="${PROJECT_ROOT}/gooze-vben-admin"
BUILD_DIR="${PROJECT_ROOT}/build"
PID_DIR="${BUILD_DIR}/pids"
LOGS_DIR="${BUILD_DIR}/logs"

API_PID_FILE="${PID_DIR}/api.pid"
ADMIN_PID_FILE="${PID_DIR}/admin.pid"
API_LOG_FILE="${LOGS_DIR}/api.log"
ADMIN_LOG_FILE="${LOGS_DIR}/admin.log"

API_PORT=8000
ADMIN_PORT=5173

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

ensure_dirs() {
    mkdir -p "${PID_DIR}" "${LOGS_DIR}"
}

log_color() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${NC}"
}

log_info()    { log_color "${BLUE}"  "[信息] $*"; }
log_success() { log_color "${GREEN}" "[成功] $*"; }
log_warn()    { log_color "${YELLOW}" "[警告] $*"; }
log_error()   { log_color "${RED}"   "[错误] $*"; }
log_header()  { log_color "${CYAN}"  "$*"; }

banner() {
    echo ""
    log_header "=========================================="
    log_header "     Gooze-CMS 管理控制台 (Linux/OSX)    "
    log_header "=========================================="
    echo ""
}

detect_os() {
    local os_type
    case "$(uname -s)" in
        Darwin*) os_type="macos" ;;
        Linux*)  os_type="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;
        *)       os_type="unknown" ;;
    esac
    echo "${os_type}"
}

is_pid_running() {
    local pid_file="$1"
    [[ -f "${pid_file}" ]] || return 1
    local pid
    pid="$(cat "${pid_file}" 2>/dev/null || true)"
    [[ -n "${pid}" ]] || return 1
    if kill -0 "${pid}" 2>/dev/null; then
        return 0
    else
        rm -f "${pid_file}"
        return 1
    fi
}

get_pid() {
    local pid_file="$1"
    if [[ -f "${pid_file}" ]]; then
        cat "${pid_file}" 2>/dev/null || true
    fi
}

is_port_in_use() {
    local port="$1"
    local os_type
    os_type="$(detect_os)"
    case "${os_type}" in
        macos)
            lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1 && return 0 || return 1
            ;;
        linux)
            (ss -tuln 2>/dev/null | grep -q ":${port}\b") && return 0 || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

print_service_status() {
    local name="$1"
    local pid_file="$2"
    local port="$3"

    local running_text pid_text port_text running_color port_color

    if is_pid_running "${pid_file}"; then
        running_text="运行中"
        running_color="${GREEN}"
        pid_text="PID: $(get_pid "${pid_file}")"
    else
        running_text="已停止"
        running_color="${RED}"
        pid_text="PID: -"
    fi

    if is_port_in_use "${port}"; then
        port_text="占用"
        port_color="${YELLOW}"
    else
        port_text="空闲"
        port_color="${GRAY}"
    fi

    echo -e "  ${BOLD}${name}${NC}"
    echo -e "    状态: ${running_color}${running_text}${NC}  |  端口(${port}): ${port_color}${port_text}${NC}  |  ${pid_text}"
    echo ""
}

cmd_status() {
    banner
    log_color "${YELLOW}" "[服务状态检查]"
    echo ""

    print_service_status "后端 API 服务"   "${API_PID_FILE}"   "${API_PORT}"
    print_service_status "前端 Admin 服务" "${ADMIN_PID_FILE}" "${ADMIN_PORT}"

    log_color "${YELLOW}" "[访问地址]"
    echo -e "  前端管理台: ${CYAN}http://localhost:${ADMIN_PORT}${NC}"
    echo -e "  后端API:    ${CYAN}http://localhost:${API_PORT}${NC}"
    echo ""
}

start_api() {
    ensure_dirs
    if is_pid_running "${API_PID_FILE}"; then
        log_warn "后端 API 服务已在运行中 (PID: $(get_pid "${API_PID_FILE}"))"
        return 0
    fi

    log_info "启动后端 API 服务..."
    cd "${API_DIR}"

    local go_env
    go_env="$(command -v go || true)"
    if [[ -z "${go_env}" ]]; then
        log_error "未检测到 Go 环境，请先安装 Go 1.24+"
        return 1
    fi

    export GO_ENV=development

    nohup go run ./cmd/admin/main.go \
        --config="./configs/admin.yaml" \
        --env=".env.admin" \
        --show=false \
        > "${API_LOG_FILE}" 2>&1 &

    local pid=$!
    echo "${pid}" > "${API_PID_FILE}"

    sleep 3
    if is_pid_running "${API_PID_FILE}"; then
        log_success "后端 API 服务已启动 (PID: ${pid}, 端口: ${API_PORT})"
    else
        log_error "后端 API 服务启动失败，请查看日志: ${API_LOG_FILE}"
        return 1
    fi
}

start_admin() {
    ensure_dirs
    if is_pid_running "${ADMIN_PID_FILE}"; then
        log_warn "前端 Admin 服务已在运行中 (PID: $(get_pid "${ADMIN_PID_FILE}"))"
        return 0
    fi

    log_info "启动前端 Admin 服务..."
    cd "${ADMIN_DIR}"

    local pnpm_cmd
    pnpm_cmd="$(command -v pnpm || true)"
    if [[ -z "${pnpm_cmd}" ]]; then
        log_error "未检测到 pnpm 环境，请先安装 pnpm 9.12+"
        return 1
    fi

    nohup pnpm dev > "${ADMIN_LOG_FILE}" 2>&1 &
    local pid=$!
    echo "${pid}" > "${ADMIN_PID_FILE}"

    sleep 5
    if is_pid_running "${ADMIN_PID_FILE}"; then
        log_success "前端 Admin 服务已启动 (PID: ${pid}, 端口: ${ADMIN_PORT})"
    else
        log_error "前端 Admin 服务启动失败，请查看日志: ${ADMIN_LOG_FILE}"
        return 1
    fi
}

cmd_start() {
    local service="${1:-all}"
    banner
    case "${service}" in
        api)   start_api ;;
        admin) start_admin ;;
        all)
            start_api
            echo ""
            start_admin
            ;;
        *)
            log_error "未知服务: ${service} (可选: api|admin|all)"
            return 1
            ;;
    esac
    echo ""
}

kill_tree() {
    local pid="$1"
    local sig="${2:-TERM}"
    if [[ -z "${pid}" ]]; then return; fi
    if kill -0 "${pid}" 2>/dev/null; then
        local children
        children="$(pgrep -P "${pid}" 2>/dev/null || true)"
        for child in ${children}; do
            kill_tree "${child}" "${sig}"
        done
        kill "-${sig}" "${pid}" 2>/dev/null || true
    fi
}

stop_api() {
    if ! is_pid_running "${API_PID_FILE}"; then
        log_color "${GRAY}" "[提示] 后端 API 服务未运行"
        return 0
    fi
    local pid
    pid="$(get_pid "${API_PID_FILE}")"
    log_color "${YELLOW}" "[停止] 后端 API 服务 (PID: ${pid})..."
    kill_tree "${pid}" TERM
    sleep 2
    if is_pid_running "${API_PID_FILE}"; then
        log_warn "优雅停止失败，强制终止..."
        kill_tree "${pid}" KILL
        sleep 1
    fi
    rm -f "${API_PID_FILE}"
    if ! is_pid_running "${API_PID_FILE}"; then
        log_success "后端 API 服务已停止"
    fi
}

stop_admin() {
    if ! is_pid_running "${ADMIN_PID_FILE}"; then
        log_color "${GRAY}" "[提示] 前端 Admin 服务未运行"
        return 0
    fi
    local pid
    pid="$(get_pid "${ADMIN_PID_FILE}")"
    log_color "${YELLOW}" "[停止] 前端 Admin 服务 (PID: ${pid})..."
    kill_tree "${pid}" TERM
    sleep 2
    if is_pid_running "${ADMIN_PID_FILE}"; then
        log_warn "优雅停止失败，强制终止..."
        kill_tree "${pid}" KILL
        sleep 1
    fi
    rm -f "${ADMIN_PID_FILE}"
    if ! is_pid_running "${ADMIN_PID_FILE}"; then
        log_success "前端 Admin 服务已停止"
    fi
}

cmd_stop() {
    local service="${1:-all}"
    banner
    case "${service}" in
        api)   stop_api ;;
        admin) stop_admin ;;
        all)
            stop_admin
            echo ""
            stop_api
            ;;
        *)
            log_error "未知服务: ${service} (可选: api|admin|all)"
            return 1
            ;;
    esac
    echo ""
}

cmd_restart() {
    local service="${1:-all}"
    banner
    log_color "${YELLOW}" "[重启] ${service} 服务..."
    echo ""
    cmd_stop "${service}"
    sleep 2
    cmd_start "${service}"
}

cmd_reload() {
    local service="${1:-all}"
    banner
    log_color "${YELLOW}" "[重载] ${service} 服务 (平滑重启)..."
    echo ""
    cmd_restart "${service}"
}

cmd_build() {
    local service="${1:-all}"
    local version="${2:-latest}"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local release_dir="${BUILD_DIR}/release-${version}-${timestamp}"

    banner
    ensure_dirs
    mkdir -p "${release_dir}"

    log_color "${YELLOW}" "[构建] 目标目录: ${release_dir}"
    echo ""

    if [[ "${service}" == "api" || "${service}" == "all" ]]; then
        log_color "${YELLOW}" "[构建] 后端 API 服务 (Go)..."
        cd "${API_DIR}"

        local go_cmd
        go_cmd="$(command -v go || true)"
        if [[ -z "${go_cmd}" ]]; then
            log_error "未检测到 Go 环境，跳过后端构建"
            echo ""
        else
            local api_build_dir="${release_dir}/api"
            mkdir -p "${api_build_dir}"

            local os_type
            os_type="$(detect_os)"
            local goos goarch bin_name
            goarch="amd64"
            case "${os_type}" in
                macos)
                    goos="darwin"
                    bin_name="gooze-admin-api"
                    ;;
                linux)
                    goos="linux"
                    bin_name="gooze-admin-api"
                    ;;
                *)
                    goos="linux"
                    bin_name="gooze-admin-api"
                    ;;
            esac

            export CGO_ENABLED=0
            export GOOS="${goos}"
            export GOARCH="${goarch}"

            local bin_path="${api_build_dir}/${bin_name}"
            if go build -ldflags "-s -w -X main.Version=${version} -X main.BuildTime=${timestamp}" \
                -o "${bin_path}" ./cmd/admin/main.go; then
                cp -r "${API_DIR}/configs" "${api_build_dir}/" 2>/dev/null || true
                cp "${API_DIR}/.env.admin" "${api_build_dir}/" 2>/dev/null || true
                local file_size
                file_size="$(du -h "${bin_path}" 2>/dev/null | cut -f1 || echo "?")"
                log_success "后端构建完成: ${bin_path} (${file_size})"
            else
                log_error "后端构建失败"
            fi
            echo ""
        fi
    fi

    if [[ "${service}" == "admin" || "${service}" == "all" ]]; then
        log_color "${YELLOW}" "[构建] 前端 Admin 服务 (Vite)..."
        cd "${ADMIN_DIR}"

        local pnpm_cmd
        pnpm_cmd="$(command -v pnpm || true)"
        if [[ -z "${pnpm_cmd}" ]]; then
            log_error "未检测到 pnpm 环境，跳过前端构建"
            echo ""
        else
            local admin_build_dir="${release_dir}/admin"
            mkdir -p "${admin_build_dir}"

            if [[ ! -d "${ADMIN_DIR}/node_modules" ]]; then
                log_color "${GRAY}" "[提示] 检测到未安装依赖，正在安装..."
                pnpm install
            fi

            if pnpm build; then
                local dist_dir="${ADMIN_DIR}/apps/admin/dist"
                if [[ -d "${dist_dir}" ]]; then
                    cp -r "${dist_dir}/." "${admin_build_dir}/"
                    local total_size
                    total_size="$(du -sh "${admin_build_dir}" 2>/dev/null | cut -f1 || echo "?")"
                    log_success "前端构建完成: ${admin_build_dir} (${total_size})"
                else
                    log_warn "前端 dist 目录未找到"
                fi
            else
                log_error "前端构建失败"
            fi
            echo ""
        fi
    fi

    log_color "${CYAN}" "[完成] 构建产物目录: ${release_dir}"
    echo ""
}

cmd_logs() {
    local service="${1:-api}"
    local log_file
    case "${service}" in
        api)   log_file="${API_LOG_FILE}" ;;
        admin) log_file="${ADMIN_LOG_FILE}" ;;
        *)
            log_error "未知服务: ${service} (可选: api|admin)"
            return 1
            ;;
    esac

    if [[ ! -f "${log_file}" ]]; then
        log_color "${GRAY}" "[提示] 日志文件不存在: ${log_file}"
        return 0
    fi

    banner
    log_color "${YELLOW}" "[日志] ${service} - ${log_file}"
    echo ""

    local tail_cmd
    tail_cmd="$(command -v tail || true)"
    if [[ -n "${tail_cmd}" ]]; then
        tail -f -n 100 "${log_file}"
    else
        cat "${log_file}"
    fi
}

cmd_clean() {
    banner
    log_color "${YELLOW}" "[清理] 清理构建产物和临时文件..."
    echo ""

    if [[ -d "${PID_DIR}" ]]; then
        for pid_file in "${PID_DIR}"/*.pid; do
            [[ -f "${pid_file}" ]] || continue
            local pid
            pid="$(cat "${pid_file}" 2>/dev/null || true)"
            if [[ -n "${pid}" ]]; then
                kill_tree "${pid}" KILL 2>/dev/null || true
            fi
        done
        rm -rf "${PID_DIR}"
        log_color "${GRAY}" "  - 已清理 PID 目录"
    fi

    [[ -d "${API_DIR}/bin" ]] && { rm -rf "${API_DIR}/bin"; log_color "${GRAY}" "  - 已清理后端 bin 目录"; }
    [[ -d "${ADMIN_DIR}/apps/admin/dist" ]] && { rm -rf "${ADMIN_DIR}/apps/admin/dist"; log_color "${GRAY}" "  - 已清理前端 dist 目录"; }

    if [[ -d "${BUILD_DIR}" ]]; then
        for release_dir in "${BUILD_DIR}"/release-*; do
            [[ -d "${release_dir}" ]] || continue
            rm -rf "${release_dir}"
            log_color "${GRAY}" "  - 已清理: $(basename "${release_dir}")"
        done
    fi

    echo ""
    log_success "清理完成"
    echo ""
}

show_help() {
    banner
    log_color "${YELLOW}" "用法:"
    echo "  ./manage.sh <命令> [参数]"
    echo ""
    log_color "${YELLOW}" "可用命令:"
    echo "  status              查看所有服务运行状态"
    echo "  start [服务]        启动服务 (api|admin|all, 默认: all)"
    echo "  stop  [服务]        停止服务 (api|admin|all, 默认: all)"
    echo "  restart [服务]      重启服务 (api|admin|all, 默认: all)"
    echo "  reload [服务]       重载服务 (api|admin|all, 默认: all)"
    echo "  build [服务] [版本] 构建打包 (api|admin|all, 默认: all)"
    echo "  logs <服务>         实时查看服务日志 (api|admin)"
    echo "  clean               清理构建产物和临时文件"
    echo "  help                显示此帮助信息"
    echo ""
    log_color "${YELLOW}" "示例:"
    echo "  ./manage.sh status              # 查看状态"
    echo "  ./manage.sh start all           # 启动全部服务"
    echo "  ./manage.sh restart api         # 重启后端"
    echo "  ./manage.sh build all v1.0.0    # 构建全部并指定版本"
    echo "  ./manage.sh logs admin          # 查看前端日志"
    echo ""
}

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    local cmd="${1,,}"
    shift || true

    case "${cmd}" in
        status)       cmd_status "$@" ;;
        start)        cmd_start  "${1:-all}" ;;
        stop)         cmd_stop   "${1:-all}" ;;
        restart)      cmd_restart "${1:-all}" ;;
        reload)       cmd_reload "${1:-all}" ;;
        build)        cmd_build  "${1:-all}" "${2:-latest}" ;;
        logs)         cmd_logs   "${1:-api}" ;;
        clean)        cmd_clean ;;
        help|--help|-h) show_help ;;
        *)
            log_error "未知命令: ${cmd}"
            echo ""
            show_help
            exit 1
            ;;
    esac

    cd "${PROJECT_ROOT}"
}

main "$@"
