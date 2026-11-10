# makima.zsh: Makima colors for zsh: prompt and command-line highlighting.
# Source: ~/.config/makima-hypr/config/zsh/makima.zsh
# Load it from the END of ~/.zshrc (after oh-my-zsh and the plugins) with:
#   [ -f ~/.config/makima-hypr/config/zsh/makima.zsh ] && . ~/.config/makima-hypr/config/zsh/makima.zsh
# Colors: ~/.config/makima-hypr/design/palette.md

# ---------- prompt: starship (replaces the oh-my-zsh theme) ----------
if command -v starship >/dev/null; then
	export STARSHIP_CONFIG=~/.config/makima-hypr/config/starship/makima.toml
	eval "$(starship init zsh)"
fi

# ---------- command line highlighting (zsh-syntax-highlighting) ----------
# Each part of what you type gets its own color, like code in an editor.
# Three color sets; pick one in ~/.zshrc BEFORE loading this file, e.g. MAKIMA_COLORS=renkli
#   tema    only the wallpaper's colors: amber, crimson, copper, teal, cream
#   renkli  the first version: adds blue paths, green strings, pink variables
#   uyumlu  (default) a palette built around amber and crimson in OKLCH: the four new colors share
#           the same perceived lightness (L 0.72-0.80) and spread around the hue wheel
#           (rose 10, sage 130, teal 210, lavender 285). Every pair of colors is at least
#           13 OKLab dE apart (tema: amber vs light amber was only 7.9)
#
#   part               example         tema              renkli            uyumlu
#   commands           cd claude       amber, bold       amber, bold       amber, bold
#   paths that exist   ~/projects/x    cream, underl.    blue, underl.     lavender, underl.
#   separators         && | ; > >>     crimson, bold     crimson, bold     crimson, bold
#   options            --continue -i   teal              teal              teal
#   strings            "hi" 'x'        copper            green             sage
#   variables, globs   $HOME *.txt     light amber       pink              rose
#   shell keywords     if for $( )     crimson           magenta           crimson
#   unknown command    cluade          crimson, underl. in all three
#   comments           # note          muted, italic in all three
typeset -A _mk
case ${MAKIMA_COLORS:-uyumlu} in
renkli) _mk=(path '#8eb0c6' str '#a9c285' var '#e07a8c' kw '#c9566b' opt '#74b3ab') ;;
tema)   _mk=(path '#e8dccb' str '#c56b46' var '#ffc266' kw '#e22e0e' opt '#74b3ab') ;;
*)      _mk=(path '#b7b6f6' str '#9fc17d' var '#f196a4' kw '#e22e0e' opt '#58b4c4') ;;
esac
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[default]='fg=#e8dccb'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e22e0e,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$_mk[kw],bold"
for s in command builtin alias suffix-alias global-alias function hashed-command arg0; do
	ZSH_HIGHLIGHT_STYLES[$s]='fg=#f2a33a,bold'
done
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#f2a33a,bold,italic'    # sudo, nohup, ...
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#e22e0e,bold'     # && || ; |
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#e22e0e,bold'          # > >> <
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#e22e0e'
ZSH_HIGHLIGHT_STYLES[path]="fg=$_mk[path],underline"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=$_mk[path]"            # a path still being typed
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$_mk[path],underline"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$_mk[opt]"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$_mk[opt]"
for s in single-quoted-argument double-quoted-argument dollar-quoted-argument back-quoted-argument; do
	ZSH_HIGHLIGHT_STYLES[$s]="fg=$_mk[str]"
	ZSH_HIGHLIGHT_STYLES[$s-unclosed]="fg=$_mk[str],underline"
done
for s in dollar-double-quoted-argument back-dollar-quoted-argument back-double-quoted-argument \
         globbing history-expansion assign; do                # $VAR in "...", *.txt, !!, NAME=value
	ZSH_HIGHLIGHT_STYLES[$s]="fg=$_mk[var]"
done
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=$_mk[kw]"   # $( )
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=$_mk[kw]"
ZSH_HIGHLIGHT_STYLES[comment]='fg=#9f7f70,italic'
# Matching brackets, by nesting level
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#f2a33a,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=$_mk[opt],bold"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=$_mk[str],bold"
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#e22e0e,bold,underline'
unset s _mk

# Gray suggestions from history (zsh-autosuggestions), accept with →
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6b5348'

# ---------- bat ----------
# Only when bat is run by name (cat stays cat). The "ansi" theme uses the terminal's
# 16 colors, which are already the Makima palette.
export BAT_THEME=ansi
