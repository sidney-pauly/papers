import pandas as pd

result = [0] * 16

for i in range(0, 16):

    s_1 = (8 & i) > 0
    s_2 = (4 & i) > 0
    s_3 = (2 & i) > 0
    s_4 = (1 & i) > 0
    
    O = (s_1 and not s_4) or (not s_2 and (s_3 ^ s_4))

    result[i] = [s_1, s_2, s_3, s_4, O]

print(pd.DataFrame(result))