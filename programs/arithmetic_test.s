main:
    MOVZ X0, #10
    MOVZ X1, #5
    MOVZ X2, #15
    MOVZ X3, #3
    
    ADD X4, X0, X1
    SUB X5, X0, X1
    ADD X6, X4, X5
    
    AND X7, X0, X2
    ORR X8, X0, X1
    
    ADD X9, X0, #25
    SUB X10, X2, #8
    
    MOVZ X11, #64
    STUR X4, [X11, #0]
    STUR X5, [X11, #8]
    STUR X6, [X11, #16]
    
    LDUR X12, [X11, #0]
    LDUR X13, [X11, #8]
    LDUR X14, [X11, #16]
    
    ADD X15, X12, X13
    SUB X16, X15, X14
    
    CBZ X16, success
    MOVZ X17, #999
    B end
    
success:
    MOVZ X9, #30
    
end:
    B end