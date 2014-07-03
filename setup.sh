#!/usr/bin/env bash

# Start from dotfiles directory
DOTFILES_SRC=$(pwd)
LOCAL_DOTFILES=${DOTFILES_SRC}/local_dotfiles

RC_FILES=".*rc
.vim"

NOP=''
NOP='echo'
if ${NOP}
    then
        echo "To actually run this file, comment out NOP='echo'."
fi

${NOP}
echo "Making local dotfile husks in ${LOCAL_DOTFILES}."
${NOP} mkdir -p ${LOCAL_DOTFILES}
for FILE in ${RC_FILES}
    do
        ${NOP}
        echo "Touching local dotfile in ${LOCAL_DOTFILES}/${FILE}."
        ${NOP} touch ${LOCAL_DOTFILES}/${FILE}
done

${NOP}
echo "Linking local dotfile directory (${LOCAL_DOTFILES}) in ~/.local."
${NOP} cd ~/.local
${NOP} ln -s ${LOCAL_DOTFILES} dotfiles

${NOP}
echo "Linking general dotfiles into ~"
${NOP} cd ~
for FILE in ${RC_FILES}
    do ${NOP} ln -s ${DOTFILES_SRC}/${FILE}
done
