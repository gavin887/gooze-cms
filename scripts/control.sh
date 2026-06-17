#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PID_DIR="$PROJECT_ROOT/.runtime"
LOG_DIR="$PROJECT_ROOT/.runtime/logs"

API_DIR="$PROJECT_ROOT/gooze-vben-api"
ADMIN_DIR="$PROJECT_ROOT/gooze-vben-admin"

API_PID_FILE="$PID_DIR/api.pid"
ADMIN_PID_FILE="$PID_DIR/admin.pid"
API_LOG_FILE="$LOG_DIR/api.log"
ADMIN_LOG_FILE="$LOG_DIR/admin.log"

API_PORT=18002
ADMIN_PORT=5173

mkdir -p "$PID_DIR"
mkdir -p "$LOG_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

usage() {
    echo ""
    echo -e "${CYAN}Gooze-CMS 服务控制脚本${NC}"
    echo ""
    echo "用法: $0 <action> [module]"
    echo ""
    echo "操作 (action):"
    echo "  start     启动服务"
    echo "  stop      停止服务"
    echo "  restart   重启服务"
    echo "  reload    重载服务（热重载）"
    echo "  status    查看服务状态"
    echo ""
    echo "模块 (module):"
    echo "  api       后端 API 服务 (gooze-vben-api, 端口 $API_PORT)"
    echo "  admin     前端管理后台 (gooze-vben-admin, 端口 $ADMIN_PORT)"
    echo "  all       所有模块 (默认)"
    echo ""
    echo "示例:"
    echo "  $0 start api          # 启动后端 API"
    echo "  $0 stop admin         # 停止前端管理后台"
    echo "  $0 restart all        # 重启所有服务"
    echo "  $0 reload api         # 热重载后端 API"
    echo "  $0 status             # 查看所有服务状态"
    echo ""
}

is_running() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || true)
        if [ -n "$procId" ] && kill -0 "$procId" 2>/dev/null; then
            return 0
        fi
        rm -f "$pid_file"
    fi
    return 1
}

get_pid_by_port() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti:"$port" 2>/dev/null
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1
    elif command -v ss >/dev/null 2>&1; then
        ss -tlnp 2>/dev/null | grep ":$port " | awk '{print $6}' | cut -d',' -f2 | cut -d'=' -f2
    fi
}

get_child_pids() {
    local parent_pid="$1"
    local children=""
    if command -v pgrep >/dev/null 2>&1; then
        children=$(pgrep -P "$parent_pid" 2>/dev/null || true)
    fi
    if [ -z "$children" ] && [ -d "/proc/$parent_pid/task" ]; then
        children=$(ls /proc/$parent_pid/task/ 2>/dev/null || true)
    fi
    local all=""
    for child in $children; do
        [ "$child" = "$parent_pid" ] && continue
        all="$all $child"
        local grand
        grand=$(get_child_pids "$child")
        if [ -n "$grand" ]; then
            all="$all $grand"
        fi
    done
    echo "$all"
}

kill_process_tree() {
    local pid="$1"
    local all_pids="$procId"
    local children
    children=$(get_child_pids "$procId")
    if [ -n "$children" ]; then
        all_pids="$all_pids $children"
    fi

    for p in $all_pids; do
        kill "$p" 2>/dev/null || true
    done

    local count=0
    local max_wait=5
    while [ $count -lt $max_wait ]; do
        local all_stopped=true
        for p in $all_pids; do
            if kill -0 "$p" 2>/dev/null; then
                all_stopped=false
                break
            fi
        done
        if $all_stopped; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done

    for p in $all_pids; do
        if kill -0 "$p" 2>/dev/null; then
            kill -9 "$p" 2>/dev/null || true
        fi
    done
}

start_api() {
    if is_running "$API_PID_FILE"; then
        echo -e "${CYAN}[INFO]${NC} 后端 API 服务已在运行 (PID: $(cat "$API_PID_FILE"))"
        return 0
    fi

    echo -e "${CYAN}[INFO]${NC} 正在启动后端 API 服务..."
    echo -e "${GRAY}       工作目录: $API_DIR${NC}"
    echo -e "${GRAY}       日志文件: $API_LOG_FILE${NC}"

    cd "$API_DIR"

    rm -f "$API_LOG_FILE"
    touch "$API_LOG_FILE"

    go run ./cmd/admin/main.go \
        --config="./configs/admin.yaml" \
        --env=".env.admin" \
        --show=false \
        > "$API_LOG_FILE" 2>&1 &

    local pid=$!
    echo "$procId" > "$API_PID_FILE"
    disown "$procId" 2>/dev/null || true

    sleep 5

    if kill -0 "$procId" 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} 后端 API 服务启动成功 (PID: $procId)"
        echo -e "${GRAY}       访问地址: http://localhost:$API_PORT${NC}"
    else
        echo -e "${RED}[ERROR]${NC} 后端 API 服务启动失败"
        if [ -f "$API_LOG_FILE" ]; then
            echo -e "${YELLOW}--- 错误日志 (最后 30 行) ---${NC}"
            tail -30 "$API_LOG_FILE" || true
            echo -e "${YELLOW}---------------------------${NC}"
        fi
        rm -f "$API_PID_FILE"
        return 1
    fi
}

start_admin() {
    if is_running "$ADMIN_PID_FILE"; then
        echo -e "${CYAN}[INFO]${NC} 前端管理后台已在运行 (PID: $(cat "$ADMIN_PID_FILE"))"
        return 0
    fi

    echo -e "${CYAN}[INFO]${NC} 正在启动前端管理后台..."
    echo -e "${GRAY}       工作目录: $ADMIN_DIR${NC}"
    echo -e "${GRAY}       日志文件: $ADMIN_LOG_FILE${NC}"

    cd "$ADMIN_DIR"

    rm -f "$ADMIN_LOG_FILE"
    touch "$ADMIN_LOG_FILE"

    pnpm dev > "$ADMIN_LOG_FILE" 2>&1 &

    local pid=$!
    echo "$procId" > "$ADMIN_PID_FILE"
    disown "$procId" 2>/dev/null || true

    sleep 8

    if kill -0 "$procId" 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} 前端管理后台启动成功 (PID: $procId)"
        echo -e "${GRAY}       访问地址: http://localhost:$ADMIN_PORT${NC}"
    else
        echo -e "${RED}[ERROR]${NC} 前端管理后台启动失败"
        if [ -f "$ADMIN_LOG_FILE" ]; then
            echo -e "${YELLOW}--- 错误日志 (最后 30 行) ---${NC}"
            tail -30 "$ADMIN_LOG_FILE" || true
            echo -e "${YELLOW}---------------------------${NC}"
        fi
        rm -f "$ADMIN_PID_FILE"
        return 1
    fi
}

stop_service() {
    local pid_file="$1"
    local service_name="$2"
    local port="${3:-}"

    if [ ! -f "$pid_file" ] && [ -z "$port" ]; then
        echo -e "${CYAN}[INFO]${NC} $service_name 未运行 (PID 文件不存在)"
        return 0
    fi

    local pids=()

    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || true)
        if [ -n "$procId" ]; then
            pids+=("$procId")
        fi
    fi

    if [ -n "$port" ]; then
        local port_pids
        port_pids=$(get_pid_by_port "$port")
        if [ -n "$port_pids" ]; then
            for p in $port_pids; do
                pids+=("$p")
            done
        fi
    fi

    if [ ${#pids[@]} -eq 0 ]; then
        echo -e "${CYAN}[INFO]${NC} $service_name 未运行"
        rm -f "$pid_file"
        return 0
    fi

    local unique_pids=()
    for p in "${pids[@]}"; do
        local found=false
        for up in "${unique_pids[@]}"; do
            if [ "$up" = "$p" ]; then
                found=true
                break
            fi
        done
        if ! $found; then
            unique_pids+=("$p")
        fi
    done

    echo -e "${CYAN}[INFO]${NC} 正在停止 $service_name (PID: ${unique_pids[*]})..."

    for pid in "${unique_pids[@]}"; do
        kill_process_tree "$procId"
    done

    local count=0
    local max_wait=10
    while [ $count -lt $max_wait ]; do
        local all_stopped=true
        for pid in "${unique_pids[@]}"; do
            if kill -0 "$procId" 2>/dev/null; then
                all_stopped=false
                break
            fi
        done
        if [ -n "$port" ]; then
            local port_pids
            port_pids=$(get_pid_by_port "$port")
            if [ -n "$port_pids" ]; then
                all_stopped=false
                for p in $port_pids; do
                    kill_process_tree "$p"
                done
            fi
        fi
        if $all_stopped; then
            break
        fi
        sleep 1
        count=$((count + 1))
    done

    for pid in "${unique_pids[@]}"; do
        if kill -0 "$procId" 2>/dev/null; then
            echo -e "${YELLOW}[WARN]${NC} 强制终止进程 $procId"
            kill -9 "$procId" 2>/dev/null || true
        fi
    done

    rm -f "$pid_file"
    echo -e "${GREEN}[OK]${NC} $service_name 已停止"
}

status_service() {
    local pid_file="$1"
    local service_name="$2"

    if is_running "$pid_file"; then
        local pid
        pid=$(cat "$pid_file")
        echo -e "${GREEN}[RUNNING]${NC} $service_name (PID: $procId)"
    else
        echo -e "${RED}[STOPPED]${NC} $service_name"
    fi
}

start_all() {
    start_api
    echo ""
    start_admin
}

stop_all() {
    stop_service "$API_PID_FILE" "后端 API 服务" "$API_PORT"
    echo ""
    stop_service "$ADMIN_PID_FILE" "前端管理后台" "$ADMIN_PORT"
}

restart_all() {
    stop_all
    echo ""
    start_all
}

reload_api() {
    if is_running "$API_PID_FILE"; then
        echo -e "${CYAN}[INFO]${NC} 正在热重载后端 API 服务..."
        stop_service "$API_PID_FILE" "后端 API 服务" "$API_PORT"
        sleep 1
        start_api
    else
        echo -e "${YELLOW}[WARN]${NC} 后端 API 服务未运行，直接启动"
        start_api
    fi
}

reload_admin() {
    if is_running "$ADMIN_PID_FILE"; then
        echo -e "${CYAN}[INFO]${NC} 前端管理后台支持热更新，无需重启"
        echo -e "${GRAY}       修改文件后会自动重新编译${NC}"
    else
        echo -e "${YELLOW}[WARN]${NC} 前端管理后台未运行，直接启动"
        start_admin
    fi
}

reload_all() {
    reload_api
    echo ""
    reload_admin
}

status_all() {
    status_service "$API_PID_FILE" "后端 API 服务"
    status_service "$ADMIN_PID_FILE" "前端管理后台"
}

ACTION="${1:-help}"
MODULE="${2:-all}"

case "$ACTION" in
    start)
        case "$MODULE" in
            api)    start_api ;;
            admin)  start_admin ;;
            all)    start_all ;;
            *)      echo -e "${RED}[ERROR]${NC} 未知模块: $MODULE"; usage; exit 1 ;;
        esac
        ;;
    stop)
        case "$MODULE" in
            api)    stop_service "$API_PID_FILE" "后端 API 服务" "$API_PORT" ;;
            admin)  stop_service "$ADMIN_PID_FILE" "前端管理后台" "$ADMIN_PORT" ;;
            all)    stop_all ;;
            *)      echo -e "${RED}[ERROR]${NC} 未知模块: $MODULE"; usage; exit 1 ;;
        esac
        ;;
    restart)
        case "$MODULE" in
            api)    stop_service "$API_PID_FILE" "后端 API 服务" "$API_PORT"; sleep 1; start_api ;;
            admin)  stop_service "$ADMIN_PID_FILE" "前端管理后台" "$ADMIN_PORT"; sleep 1; start_admin ;;
            all)    restart_all ;;
            *)      echo -e "${RED}[ERROR]${NC} 未知模块: $MODULE"; usage; exit 1 ;;
        esac
        ;;
    reload)
        case "$MODULE" in
            api)    reload_api ;;
            admin)  reload_admin ;;
            all)    reload_all ;;
            *)      echo -e "${RED}[ERROR]${NC} 未知模块: $MODULE"; usage; exit 1 ;;
        esac
        ;;
    status)
        status_all
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} 未知操作: $ACTION"
        usage
        exit 1
        ;;
esac
