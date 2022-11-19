# Disable prompt for virtual environment (python)
# ! for conda use the .condarc file and set env_prompt: ''
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1

oh-my-posh init pwsh --config "https://raw.githubusercontent.com/Lucino772/stuff/main/dotfiles/ohmyposh/lucino772.omp.json" | Invoke-Expression
