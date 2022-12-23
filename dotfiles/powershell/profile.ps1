# Disable prompt for virtual environment (python)
# ! for conda use the .condarc file and set env_prompt: ''
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
$env:OHMYPOSH_THEME = '~/.ohmyposh_themes/lucino772.omp.json'

oh-my-posh init pwsh --config "$env:OHMYPOSH_THEME" | Invoke-Expression
