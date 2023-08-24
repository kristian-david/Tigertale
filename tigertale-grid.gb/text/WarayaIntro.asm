;============================================================================================================================
; Dialogue Tree
;============================================================================================================================
; SECTION "Waraya Intro Dialogue Tree", ROM0
WarayaIntro:
    call EnableOrContinueDialogue

    call ChangeText
    ; ld hl,
    ; ld de, _WarayaIntroText
    ;Load _WarayaIntroText
    ;PrintDialogue

ret

;============================================================================================================================
; Dialogue Text
; 18 Characters per line only
;============================================================================================================================

; SECTION "Waraya Intro Dialogue Texts", ROM0
_WarayaName::
    db "Waraya the Wise", 0
.end

; This will just be printed
_WarayaIntroText::
    db "Oh, my dear, look", BR
    db "at how much you've", BR
    db "grown!", CNT

    db "It feels like    ", BR
    db "yesterday when you", BR
    db "were a little cub.", CNT

    db "Now here you are,", BR
    db "running faster    ", BR
    db "than a cheetah! ", CNT, 0, NXT   ;If NXT is found progression will be incremented
.end

; _WarayaChoices1::
;     db CHOICE_YES, "Thanks!", _YES_1_Text
;     db CHOICE_NO, "I doubt", _NO_1_Text
;     db CHOICE_RPT "Sorry?", _WarayaIntroText    ; Don't make the player speak, just repeat the question.
;     db CHOICE_MSC "(Joke)", _MSC_1_Text

_YES_1_Text:
    db "Thanks Mom, I've ", BR
    db "been practicing a ", BR
    db "lot!", CNT, 0, NXT

_NO_1_Text:
    db "I don't think so ", BR
    db "Mom.", CNT

    db "I still feel far  ", BR
    db "from being a      ", BR
    db "fierce hunter.",  CNT, 0, NXT

_MSC_1_Text:
    db "You're still fast", BR
    db "Mom.", CNT

    db "In fact, you can", BR
    db "still win in a    ", BR
    db "race.", CNT

    db "If you're going  ", BR
    db "against snails.", CNT, 0, NXT

    