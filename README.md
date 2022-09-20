# BeamClassOverhaul
Aims to solve the problem that beam weapons stop firing until the full rof reaching its end , once losing targets . 

Instruction :
weapon.readyToFire == weapon.beNotCooling + unit.turretAlignedToTheTarget
Weapons that are not cooling are given a fire command after the turret had rotated to its place where it can physically hit the target.
1.8ROF means that it won't spam triggering OnFire event , as well not low to that degree that it refuses to respond even if the turret's orientation had been set up properly
BeamLifetime doesn't make sense here.
Basically , it's not handled in the engine, but in lua. Thus I changed the code and for now the game ignores this field. Originally it was used to define the lifetime of beam. Everytime after the OnFire has been triggered, the game spawns a beam and holds it for BeamLifetime seconds (Probably) , and then destroy it. Take a look of the  Satellite , You know what I mean .
BeamCollisionDelay ibid. Originally, the higher its value, the less damage it deals per second, which means the lower the resolution.
