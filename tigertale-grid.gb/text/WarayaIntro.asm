; _WarayaIntro::
; 	text "I am AGATHA of"
; 	line "the ELITE FOUR!"

; 	para "OAK's taken a lot"
; 	line "of interest in"
; 	cont "you, child!"

; 	para "That old duff was"
; 	line "once tough and"
; 	cont "handsome! That"
; 	cont "was decades ago!"

; 	para "Now he just wants"
; 	line "to fiddle with"
; 	cont "his #DEX! He's"
; 	cont "wrong! #MON"
; 	cont "are for fighting!"

; 	para "<PLAYER>! I'll show"
; 	line "you how a real"
; 	cont "trainer fights!"
; 	done

; 18 Characters per line only

_WarayaName::
    db "Waraya the Wise", 0
.end

_WarayaIntro::
    db "Oh, my dear, look", BR           ;1 End of line
    db "at how much you've", BR   ;2 Arrow to continue next set of lines
    db "grown!", CNT   ;0 End of dialogue

    db "It feels like    ", BR           ;1 End of line
    db "yesterday you were", BR   ;2 Arrow to continue next set of lines
    db "a little cub.", CNT   ;0 End of dialogue

    db "Now here you are,", BR           ;1 End of line
    db "running faster    ", BR   ;2 Arrow to continue next set of lines
    db "than a cheetah!", END   ;0 End of dialogue