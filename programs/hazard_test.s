main:
    MOVZ X0, #8
    MOVZ X10, #42
    STUR X10, [X0, #0]
    
    LDUR X1, [X0, #0]
    ADD X2, X1, X1
    SUB X3, X2, X1
    
    ADD X4, X1, X2
    ADD X5, X4, X1
    
    STUR X5, [X0, #4]
    LDUR X6, [X0, #4]
    ADD X7, X6, X5
    
    SUB X8, X7, X6
    CBZ X8, end
    ADD X9, X8, #1
    
end:
    MOVZ X9, #30
    B end