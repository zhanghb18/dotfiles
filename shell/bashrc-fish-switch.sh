# --- dotfiles: interactive bash -> fish ---------------------------------------
# 追加到 ~/.bashrc 末尾。不要 chsh 成 fish。
#
# /etc/passwd 里的登录 shell 必须保持 POSIX 兼容:VSCode Remote-SSH 的 bootstrap
# 走 `ssh host bash -c '...'`,fish 解析不了那段脚本,症状是
# "Connecting with SSH timed out"。驱动 shell 的 agent(Claude Code 的 Bash
# 工具)同样按 bash 来。所以登录 shell 留 bash,只在纯交互终端里交给 fish。
#
# 以下情况留在 bash:
#   - 带命令进来        BASH_EXECUTION_STRING  (如 ssh host 'cmd')
#   - stdin/stdout 非 tty                      (管道、agent、脚本)
#   - VSCode server 内  VSCODE_AGENT_FOLDER
#   - 临时想留 bash     NO_FISH=1 ssh host     (也可以 bash --norc)
if [ -z "${BASH_EXECUTION_STRING:-}" ] &&
   [ -t 0 ] && [ -t 1 ] &&
   [ -z "${NO_FISH:-}" ] &&
   [ -z "${VSCODE_AGENT_FOLDER:-}" ] &&
   command -v fish >/dev/null 2>&1; then
    exec fish
fi
# --- end dotfiles: interactive bash -> fish -----------------------------------
