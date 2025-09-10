main:
    MOVZ X1, #5
    MOVZ X2, #0
    
loop:
    ADD X2, X2, X1
    SUB X1, X1, #1
    CBZ X1, end_loop
    B loop
    
end_loop:
    MOVZ X3, #10
    MOVZ X4, #0
    
inner_loop:
    ADD X4, X4, #2
    SUB X3, X3, #1
    CBZ X3, final
    
    AND X5, X3, #1
    CBZ X5, even
    ADD X4, X4, #1
    B inner_loop
    
even:
    SUB X4, X4, #1
    B inner_loop
    
final:
    ADD X6, X2, X4
    MOVZ X9, #30
    B final