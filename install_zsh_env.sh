#!/bin/bash
# Script d'installation de zsh + oh-my-zsh + powerlevel10k + plugins
# Auteur : Mariam Guerraf

echo "🔧 Installation de l'environnement Zsh..."

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
	echo "🍺 Installation de Homebrew..."
	git clone https://github.com/Homebrew/brew ~/goinfre/homebrew
	eval "$(/Users/$USER/goinfre/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew déjà installé."
fi

# --- Installer les plugins ---
brew install zsh powerlevel10k zsh-autosuggestions zsh-syntax-highlighting

# --- Installer Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "💡 Installation de Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh déjà présent."
fi

# --- Configurer .zshrc ---
echo "⚙️  Mise à jour du fichier .zshrc..."
cat << 'EOF' > ~/.zshrc
alias mb='make bonus'

# Homebrew
export PATH="$HOME/goinfre/homebrew/bin:$PATH"
eval "$(/Users/$USER/goinfre/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Powerlevel10k
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# Plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable colors
autoload -U colors && colors

# Powerlevel10k Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "✅ Installation terminée !"
echo "➡️ Ouvre un nouveau terminal ou fais : source ~/.zshrc"
