extends Control

# Define as configurações Mecânicas do Jogo.

export var Godot = true

# Define as configurações do Físicas do Cenário.

export var Gravity = 50.0

# Define as configurações do Player.

export var Player_Damage = 5.0
export var Player_Health = 9999.0
export var Player_Hit_Rate = 1.0

export var Player_Walk_Speed = 4.0
export var Player_Run_Speed = 8.0
export var Player_Jump_Strength = 15.0

# Define as configurações do NPC: Simba.

export var Simba_Health = 25.0
export var Simba_Damage = 5.0
export var Simba_Damage_Critical = 0.2
export var Simba_Hit_Rate = 0.8
export var Simba_Hit_Rate_Critical = 0.3

export var Simba_Walk_Speed = 4.0
export var Simba_Run_Speed = 8.0
export var Simba_Jump_Strength = 15.0

# Define as configurações dos Inimigos: Gram.

export var Gram_Rate = 12.0

export var Gram_Health = 25.0
export var Gram_Damage = 5.0
export var Gram_Damage_Critical = 0.2
export var Gram_Hit_Rate = 0.8
export var Gram_Hit_Rate_Critical = 0.3

export var Gram_Walk_Speed = 3.0
export var Gram_Run_Speed = 6.0
export var Gram_Jump_Strength = 30.0

# Define as configurações do Spawner dos Inimigos: Gram.

export var Spawner_Gram = 4.0
export var Spawner_Gram_Rate = 12.0
export var Spawner_Gram_Generation_Time = 5.0

# Define as configurações do Bônus: Heart.

export var Bonus_Heart = 4.0
export var Bonus_Heart_Recharge = 25.0
