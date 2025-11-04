#!/usr/bin/env bash
# Script d'installation de zsh + oh-my-zsh + powerlevel10k + plugins
# Auteur adapté pour Mariam Guerraf
set -euo pipefail

echo "🔧 Installation de l'environnement Zsh..."

# Variables
BREW_DIR="$HOME/goinfre/homebrew"   # change si tu veux l'emplacement standard
BREW_BIN="$BREW_DIR/bin/brew"
BREW_PREFIX_CMD=""

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
	echo "🍺 Homebrew non trouvé."
	# Si tu es dans un environnement où goinfre est requis (ex: 42), on clone, sinon on utilise l'install officiel.
	read -p "Veux-tu installer Homebrew dans $BREW_DIR (y/N) ? " -r REPLY
	REPLY=${REPLY,,}
	if [[ "$REPLY" == "y" || "$REPLY" == "yes" ]]; then
		echo "Clonage de Homebrew dans $BREW_DIR..."
	mkdir -p "$HOME/goinfre"
	git clone https://github.com/Homebrew/brew "$BREW_DIR"
	eval "$($BREW_BIN shellenv)"
  else
	echo "Installation officielle Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# charge brew dans la session
	if command -v brew &>/dev/null; then
	  eval "$(brew shellenv)"
	fi
  fi
else
  echo "✅ Homebrew déjà installé."
  eval "$(brew shellenv)" || true
fi

# --- Installer les paquets ---
echo "📦 Installation de zsh, powerlevel10k et plugins via brew..."
brew install zsh powerlevel10k zsh-autosuggestions zsh-syntax-highlighting || true

# --- Installer Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "💡 Installation de Oh My Zsh..."
  # --unattended évite prompt interactif
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
else
  echo "✅ Oh My Zsh déjà présent."
fi

# --- Mettre à jour ~/.zshrc proprement ---
ZSHRC="$HOME/.zshrc"
echo "⚙️  Mise à jour du fichier $ZSHRC..."

# Bloc à ajouter
read -r -d '' ADD_BLOCK <<'EOF' || true
# ---- Gestion Homebrew pour session ----
export PATH="$HOME/goinfre/homebrew/bin:$PATH"
eval "$(brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Powerlevel10k
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

# Plugins
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Enable colors
autoload -U colors && colors

# Powerlevel10k Config if exists
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

# N'ajoute que si absent
if ! grep -Fq "powerlevel10k/powerlevel10k.zsh-theme" "$ZSHRC" 2>/dev/null; then
  printf "\n%s\n" "$ADD_BLOCK" >> "$ZSHRC"
  echo "✅ Bloc ajouté à $ZSHRC."
else
  echo "ℹ️  Configuration déjà présente dans $ZSHRC, pas d'ajout."
fi

# --- Option : rendre zsh shell par défaut ---
if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "ℹ️  Ton shell courant n'est pas zsh."
  read -p "Souhaites-tu changer le shell par défaut pour zsh maintenant ? (chsh) (y/N) " -r REPLY
  REPLY=${REPLY,,}
  if [[ "$REPLY" == "y" || "$REPLY" == "yes" ]]; then
	CHSH_PATH="$(which zsh || true)"
	if [ -n "$CHSH_PATH" ]; then
	  echo "Exécution de chsh -s $CHSH_PATH (tu devras entrer ton mot de passe)..."
	  chsh -s "$CHSH_PATH" || echo "⚠️  chsh a échoué ou demande un mot de passe. Tu peux le lancer manuellement : chsh -s $(which zsh)"
	else
	  echo "⚠️  zsh introuvable pour chsh."
	fi
  fi
else
  echo "✅ Ton shell par défaut est déjà zsh."
fi

# --- Appliquer dans la session courante ---
echo "🔁 Application des changements dans la session courante..."
# Assure que brew est chargé
eval "$(brew shellenv)" || true

# Recharge .zshrc dans la session actuelle (si tu veux rester dans bash tu peux sourcer manuellement)
# Remarque : exec zsh remplace le shell courant par zsh (utile pour tester immédiatement)
read -p "Veux-tu démarrer zsh maintenant dans cette session (exec zsh) ? (y/N) " -r REPLY
REPLY=${REPLY,,}
if [[ "$REPLY" == "y" || "$REPLY" == "yes" ]]; then
  echo "➡️ Démarrage de zsh..."
  exec zsh
else
  echo "ℹ️  Pour appliquer manuellement sans redémarrer, exécute : source ~/.zshrc"
fi

echo "✅ Installation terminée."