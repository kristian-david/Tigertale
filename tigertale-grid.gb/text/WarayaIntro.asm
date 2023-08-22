

; 18 Characters per line only

_WarayaName::
    db "Waraya the Wise", 0
.end

_WarayaIntro::
    db "Oh, my dear, look", BR
    db "at how much you've", BR
    db "grown!", CNT

    db "It feels like    ", BR
    db "yesterday you were", BR
    db "a little cub.", CNT

    db "Now here you are,", BR
    db "running faster    ", BR
    db "than a cheetah!", CNT, 0, NXT
.end


    ; db CHOICE_YES, "Thanks!", _YES_1
    ; db CHOICE_NO, "I doubt", _NO_1
    ; db CHOICE_RPT "Sorry?", _WarayaIntro
    ; db CHOICE_MSC "SRCSTIC", _MSC_1

_YES_1:
    db "Thanks Mom"