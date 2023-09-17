# Permission bits

# ur User +r bit
# uw User +w bit
# ux User +x bit (files)
# ue User +x bit (file types)
# gr Group +r bit
# gw Group +w bit
# gx Group +x bit
# tr Others +r bit
# tw Others +w bit
# tx Others +x bit
# su Higher bits (files)
# sf Higher bits (other types)
# xa Extended attribute marker

# File sizes

# sn Size numbers
# sb Size unit
# df Major device ID
# ds Minor device ID

# Owners and Groups

# uu A user that’s you
# un A user that’s not
# gu A group with you in it
# gn A group without you

# Hard links

# lc Number of links
# lm A multi-link file

# Git

# ga New
# gm Modified
# gd Deleted
# gv Renamed
# gt Type change

# Details and metadata

# xx Punctuation
# da Timestamp
# in File inode
# bl Number of blocks
# hd Table header row
# lp Symlink path
# cc Control character

function set_colours() {

    local permission_colour='38;5;242'
    local user_colour='38;5;38'

    local exa_colors_values=(
        reset
        ur="${permission_colour}"
        uw="${permission_colour}"
        ux="${permission_colour}"
        ue="${permission_colour}"
        gr="${permission_colour}"
        gw="${permission_colour}"
        gx="${permission_colour}"
        tr="${permission_colour}"
        tw="${permission_colour}"
        tx="${permission_colour}"
        su="${permission_colour}"
        sf="${permission_colour}"
        xa="${permission_colour}"
        uu="${user_colour}"
        un="${user_colour}"
        gu="${user_colour}"
        gn="${user_colour}"
        da="38;5;251"
        ga='38;5;38'
        gm='38;5;142'
        gd='38;5;124'
        sn='38;5;105'
        sb='38;5;129'
    )
    EXA_COLORS="$(tr ' ' ':' <<<"${exa_colors_values[@]}")"
}

EXA_COLORS=""
set_colours
export EXA_COLORS
