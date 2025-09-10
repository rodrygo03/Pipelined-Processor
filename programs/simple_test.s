main:
    MOVZ X0, #10
    MOVZ X1, #5
    ADD X2, X0, X1
    SUB X3, X0, X1
    AND X4, X0, X1
    ORR X5, X0, X1
    ADD X6, X2, #15
    ADD X9, X6, #0
    B end
end:
    B end