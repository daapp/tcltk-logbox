package provide logbox 0.1

package require Tk
package require Ttk
package require snit

package require msgcat


# todo: add menu items "copy" and "cut"

option add *Logbox.menu.tearOff false

snit::widget widget::logbox {
    hulltype ttk::frame

    component list -public list

    option -lines -default 1000
    # tag: {tagName {foreground background} ...}
    option -tags -default ""

    delegate option * to hull

    variable log [list]; # for listbox

    constructor {args} {
        ttk::scrollbar $win.sx -orient horizontal -command [list $win.list xview]
        ttk::scrollbar $win.sy -orient vertical   -command [list $win.list yview]

        install list using listbox $win.list -height 1 \
            -listvariable [myvar log] \
            -xscrollcommand [list $win.sx set] \
            -yscrollcommand [list $win.sy set]

        grid $win.sy -row 0 -column 1 -sticky ns
        grid $win.sx -row 1 -column 0 -sticky ew
        grid $win.list -row 0 -column 0 -sticky nsew

        grid columnconfigure $win $win.list -weight 1
        grid rowconfigure    $win $win.list -weight 1

        menu $win.menu
        $win.menu add command -label [msgcat::mc "Save"]  -command [mymethod save]
        $win.menu add command -label [msgcat::mc "Clear"] -command [mymethod clear]

        bind $win.list <Button-3> [list tk_popup $win.menu %X %Y]

        $self configurelist $args
    }


    method clear {} {
        set log [list]
    }


    # add ?-tag name? ?fmt? message
    method add {args} {
        set tag [from args -tag ""]

        if {[llength $args] == 1} {
            lappend log [lindex $args 0]
        } else {
            lappend log [msgcat::mc {*}$args]
        }

        if {$tag ne "" && [dict exists $options(-tags) $tag]} {
            lassign [dict get $options(-tags) $tag] fg bg
            $list itemconfigure end -foreground $fg -background $bg
        }

        if {[$list index end] > $options(-lines)} {
            $list delete 0
        }

        $list yview end

        return
    }


    method save {{filename ""}} {
        if {$filename eq ""} {
            set filename [tk_getSaveFile -filetypes {{{All Files} *}}]

            if {$filename != ""} {
                $self SaveToFile $filename
            }
        } else {
            $self SaveToFile $filename
        }
    }


    method SaveToFile {filename} {
        if {[catch {set f [open $filename w]} errorMessage]} {
            tk_messageBox -type ok -icon error \
                -message [msgcat::mc "Can't write to file %s: %s" \
                              $filename $errorMessage]
        } else {
            puts $f [join $log \n]
            close $f
        }
    }
}
