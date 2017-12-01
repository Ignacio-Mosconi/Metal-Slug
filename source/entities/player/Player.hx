package entities.player;

import entities.Entity;
import flixel.system.FlxSound;
import others.Collectable;
import weapons.Bullet;
import weapons.Grenade;
import weapons.Knife;
import weapons.Weapon;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.effects.FlxTrail;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

enum State
{
	IDLE;
	MOVING;
	PREJUMPING;
	JUMPING;
	LANDING;
	CROUCHED;
	STABBING;
	AIMING_UPWARDS;
	SHOOTING;
	RELOADING;
	THROWING_GRENADE;
	DYING;
}

class Player extends Entity
{
	static public var lives(get, null):Int;
	public var currentState(get, null):State;
	private var speed:Int;
	private var jumpSpeed:Int;
	public var knife(get, null):Knife;
	public var pistolBullets(get, null):FlxTypedGroup<Bullet>;
	public var grenades(get, null):FlxTypedGroup<Grenade>;
	private var hasJustJumped:Bool;
	private var hasJustShot:Bool;
	private var hasJustLaunchedBullet:Bool;
	private var hasJustReloaded:Bool;
	private var hasJustThrownGrenade:Bool;
	private var hasJustLaunchedGrenade:Bool;
	private var shootingCooldown:Float;
	private var isAimingUpwards:Bool;
	public var totalAmmo(get, null):Int;
	private var magAmmo:Int;
	public var grenadesAmmo(get, null):Int;
	public var hasJustBeenHit(get, null):Bool;
	@:isVar public var hasJustPickedUpCollectable(get, set):Bool;
	public var hasLost(get, null):Bool;
	private var powerUpState:FlxTrail;
	public var isInvincible(get, null):Bool;
	private var invincibilityTime:Float;
	private var footStepSound:FlxSound;
	private var jumpSound:FlxSound;
	private var knifeSlashSound:FlxSound;
	private var pistolShotSound:FlxSound;
	private var pistolEmptyMagSound:FlxSound;
	private var pistolReloadSound:FlxSound;
	private var throwGrenadeSound:FlxSound;
	private var pickUpCollectableSound:FlxSound;
	private var powerUpSound:FlxSound;
	private var deathSound:FlxSound;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);
		
		// Graphics, Animations & Sound Effects
		loadGraphic(AssetPaths.player__png, true, 80, 64, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animationsSetUp();
		soundEffectsSetUp();
		
		// Attributes Initialization
		lives = Reg.playerMaxLives;
		width = 40;
		currentState = State.IDLE;
		speed = Reg.playerNormalSpeed;
		jumpSpeed = Reg.playerJumpSpeed;
		acceleration.y = Reg.gravity;
		hasJustJumped = false;
		hasJustShot = false;
		hasJustLaunchedBullet = false;
		hasJustReloaded = false;
		hasJustThrownGrenade = false;
		hasJustLaunchedGrenade = false;
		shootingCooldown = 0;
		isAimingUpwards = false;
		totalAmmo = Reg.pistolMaxAmmo;
		magAmmo = Reg.pistolMagSize;
		grenadesAmmo = Reg.maxGrenades;
		hasJustBeenHit = false;
		hasJustPickedUpCollectable = false;
		hasLost = false;
		isInvincible = false;
		invincibilityTime = 0;
		
		// Weapons Creation
		knife = new Knife();
		knife.kill();
		FlxG.state.add(knife);
		pistolBullets = new FlxTypedGroup<Bullet>();
		FlxG.state.add(pistolBullets);
		grenades = new FlxTypedGroup<Grenade>();
		FlxG.state.add(grenades);
		
		// Power Up Creation
		powerUpState = new FlxTrail(this, null, 4, 20, 0.4, 0.1);
		powerUpState.active = false;
		FlxG.state.add(powerUpState);
	}

	override public function update(elapsed:Float)
	{
		stateMachine(elapsed);
		checkHitboxOffset();
		checkInvincibilty(elapsed);
		checkDeathFromFalling();
		
		super.update(elapsed);
	}

	private function stateMachine(elapsed:Float)
	{
		switch (currentState)
		{
			case State.IDLE:
				animation.play("idle");
				
				move();
				jump();
				crouch();
				stab();
				aimUpwards();
				shoot(elapsed);
				reload();
				throwGrenade();
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (hasJustThrownGrenade)
						currentState = State.THROWING_GRENADE;
					else
					{
						if (hasJustReloaded)
							currentState = State.RELOADING;
						else
						{
							if (hasJustShot && shootingCooldown == 0)
								currentState = State.SHOOTING;
							else
							{
								if (isAimingUpwards)
									currentState = State.AIMING_UPWARDS;
								else
								{
									if (knife.alive)
										currentState = State.STABBING;
									else
									{
										if (height == Reg.playerCrouchedHeight)
											currentState = State.CROUCHED;
										else
										{
											if (hasJustJumped)
												currentState = State.PREJUMPING
											else
												if (velocity.x != 0)
													currentState = State.MOVING;
										}
									}
								}
							}
						}
					}
				}

			case State.MOVING:
				animation.play("move");
				footStepSound.play(false, 0, 700);
				
				move();
				jump();
				stab();
				shoot(elapsed);
				throwGrenade();
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (hasJustThrownGrenade)
						currentState = State.THROWING_GRENADE;
					else
					{
						if (hasJustShot && shootingCooldown == 0)
							currentState = State.SHOOTING;
						else
						{
							if (knife.alive)
								currentState = State.STABBING;
							else
							{
								if (hasJustJumped)
									currentState = State.PREJUMPING;
								else
									if (velocity.x == 0)
										currentState = State.IDLE;
							}
						}
					}
				}

			case State.PREJUMPING:
				if (animation.name != "preJump")
				{
					animation.play("preJump");
					jumpSound.play();
				}
					
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (animation.name == "preJump" && animation.finished)
					{
						hasJustJumped = false;
						velocity.y = jumpSpeed;
						currentState = State.JUMPING;
					}
				}

			case State.JUMPING:
				if (animation.name != "jump")
					animation.play("jump");
				
				stab();
				shoot(elapsed);
				throwGrenade();

				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (hasJustThrownGrenade)
						currentState = State.THROWING_GRENADE;
					else
					{
						if (hasJustShot && shootingCooldown == 0)
							currentState = State.SHOOTING;
						else
						{
							if (knife.alive)
								currentState = State.STABBING;
							else
								if (velocity.y == 0)
									currentState = State.LANDING;
						}	
					}
				}

			case State.LANDING:
				if (animation.name != "land")
					animation.play("land");

				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (animation.name == "land" && animation.finished)
					{
						if (velocity.x != 0)
							currentState = State.MOVING;
						else
							currentState = State.IDLE;
					}
				}

			case State.CROUCHED:
				if (animation.name != "crouch" && animation.name != "crouchStab" 
				&& animation.name != "crouchShoot" && animation.name != "crouchThrowGrenade")
				{
					if (animation.name != "postCrouchStab")
						animation.play("crouch");
				}
				else
					if (animation.name != "postCrouchStab")
						animation.play("postCrouchStab");
				stab();
				shoot(elapsed);
				throwGrenade();
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (hasJustThrownGrenade)
						currentState = State.THROWING_GRENADE;
					else
					{
						if (hasJustShot && shootingCooldown == 0)
							currentState = State.SHOOTING;
						else
						{
							if (knife.alive)
								currentState = State.STABBING;
							else 
								if (!FlxG.keys.pressed.DOWN)
								{
									y -= 16;
									height = Reg.playerStandingHeight;
									offset.y = 0;
									currentState = State.IDLE;
								}
						}
					}
				}

			case State.STABBING:
				if (height == Reg.playerStandingHeight)
				{
					if (animation.name != "stab")
					{
						animation.play("stab");
						knifeSlashSound.play();
					}
				}
				else
					if (animation.name != "crouchStab")
					{
						animation.play("crouchStab");
						knifeSlashSound.play();
					}
					
				if (velocity.y == 0)
					velocity.x = 0;
				knife.x = (facing == FlxObject.LEFT) ? x - knife.width: x + width;
				knife.y = y + height / 2 - knife.height / 2;
	
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if ((animation.name == "stab" || animation.name == "crouchStab") && animation.finished)
					{
						knife.kill();
						
						if (height == Reg.playerCrouchedHeight)
							currentState = State.CROUCHED;
						else
						{
							if (velocity.y != 0)
								currentState = State.JUMPING;
							else
							{
								if (velocity.x != 0)
									currentState = State.MOVING;
								else
									currentState = State.IDLE;
							}
						}
					}
				}
				
			case State.AIMING_UPWARDS:
				animation.play("aimUpwards");
				
				stab();
				shoot(elapsed);
				reload();
				throwGrenade();
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
				{
					isAimingUpwards = false;
					currentState = State.DYING;
				}
				else
				{
					if (hasJustThrownGrenade)
					{
						isAimingUpwards = false;
						currentState = State.THROWING_GRENADE;
					}
					else
					{
						if (hasJustReloaded)
						{
							isAimingUpwards = false;
							currentState = State.RELOADING;
						}
						else
						{
							if (hasJustShot && shootingCooldown == 0)
								currentState = State.SHOOTING;
							else
							{
								if (knife.alive)
								{
									isAimingUpwards = false;
									currentState = State.STABBING;
								}
								else
									if (!FlxG.keys.pressed.UP)
									{
										isAimingUpwards = false;
										currentState = State.IDLE;
									}
							}
						}
					}
				}
				
			case State.SHOOTING:
				if (height == Reg.playerStandingHeight && !isAimingUpwards)
				{
					if (animation.name != "shoot")
						animation.play("shoot");
				}
				else
				{
					if (height == Reg.playerCrouchedHeight)
					{
						if (animation.name != "crouchShoot")
							animation.play("crouchShoot");
					}
					else
						if (animation.name != "shootUpwards")
							animation.play("shootUpwards");
				}
					
				if (velocity.y == 0)
					velocity.x = 0;
					
				if ((animation.name == "shoot" || animation.name == "crouchShoot" || animation.name == "shootUpwards")
				&& animation.curAnim.curFrame == 1 && !hasJustLaunchedBullet)
				{
					hasJustLaunchedBullet = true;
					pistolShotSound.play(true);
					launchBullet();
				}
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if ((animation.name == "shoot" || animation.name == "crouchShoot" || animation.name == "shootUpwards") 
						&& animation.finished)
					{
						hasJustLaunchedBullet = false;
						
						if (isAimingUpwards)
							currentState = State.AIMING_UPWARDS;
						else
						{
							if (height == Reg.playerCrouchedHeight)
								currentState = State.CROUCHED;
							else
							{
								if (velocity.y != 0)
									currentState = State.JUMPING;
								else
								{
									if (velocity.x != 0)
										currentState = State.MOVING;
									else
										currentState = State.IDLE;
								}
							}
						}
					}
				}
				
			case State.RELOADING:
				if (animation.name != "reload")
				{
					animation.play("reload");
					pistolReloadSound.play(true, 0, 1000);
				}
				
				velocity.x = 0;
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if (animation.name == "reload" && animation.finished)
					{
						hasJustReloaded = false;
						if (isAimingUpwards)
							currentState = State.AIMING_UPWARDS;
						else
							currentState = State.IDLE;
					}
				}
					
			case State.THROWING_GRENADE:
				if (height == Reg.playerStandingHeight)
				{
					if (animation.name != "throwGrenade")
					{
						animation.play("throwGrenade");
						throwGrenadeSound.play();
					}
				}
				else
					if (animation.name != "crouchThrowGrenade")
					{
						animation.play("crouchThrowGrenade");
						throwGrenadeSound.play();
					}
						
				if (velocity.y == 0)
					velocity.x = 0;
					
				if ((animation.name == "throwGrenade" || animation.name == "crouchThrowGrenade") && animation.curAnim.curFrame == 2
				&& !hasJustLaunchedGrenade)
				{
					hasJustLaunchedGrenade = true;
					launchGrenade();
				}
				
				if (hasJustBeenHit && !FlxFlicker.isFlickering(this))
					currentState = State.DYING;
				else
				{
					if ((animation.name == "throwGrenade" || animation.name == "crouchThrowGrenade") && animation.finished)
					{
						hasJustLaunchedGrenade = false;
						
						if (isAimingUpwards)
							currentState = State.AIMING_UPWARDS;
						else
						{
							if (height == Reg.playerCrouchedHeight)
								currentState = State.CROUCHED;
							else
							{
								if (velocity.y != 0)
									currentState = State.JUMPING;
								else
								{
									if (velocity.x != 0)
										currentState = State.MOVING;
									else
										currentState = State.IDLE;
								}
							}
						}
					}
				}
				
				case State.DYING:
					if (animation.name != "die")
					{
						animation.play("die");
						deathSound.play();
					}

					velocity.x = 0;	
						
					if (animation.name == "die" && animation.finished)
						kill();
		}
	}
	
	// Action Methods
	private function move():Void
	{
		velocity.x = 0;
		if (FlxG.keys.pressed.LEFT)
		{
			facing = FlxObject.LEFT;
			velocity.x = -speed;
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			facing = FlxObject.RIGHT;
			velocity.x = speed;
		}
	}

	private function jump():Void
	{
		if (FlxG.keys.justPressed.S)
		{
			hasJustJumped = true;
		}
	}

	private function crouch():Void
	{
		if (FlxG.keys.pressed.DOWN)
		{
			velocity.x = 0;
			y += 16;
			height = Reg.playerCrouchedHeight;
			offset.y = 16;
		}
	}

	private function stab():Void
	{
		if (FlxG.keys.justPressed.D)
		{
			Weapon.directionToFace = facing;
			if (facing == FlxObject.LEFT)
				knife.reset(x - knife.width, y + height / 2 - knife.height / 2);
			else
				knife.reset(x + width, y + height / 2 - knife.height / 2);
		}
	}
	
	private function aimUpwards():Void
	{
		if (FlxG.keys.pressed.UP)
			isAimingUpwards = true;
	}
	
	private function shoot(time:Float):Void
	{
		if (FlxG.keys.justPressed.A && !hasJustShot && magAmmo > 0)
		{
			hasJustShot = true;
			shootingCooldown = 0;
			magAmmo--;
		}
		else
		{
			if (FlxG.keys.justPressed.A && magAmmo == 0)
				pistolEmptyMagSound.play();
			shootingCooldown += time;
			if (shootingCooldown >= Reg.pistolRateOfFire)
				hasJustShot = false;
		}
	}
	
	private function reload():Void
	{
		if (FlxG.keys.justPressed.W)
		{
			if (totalAmmo >= Reg.pistolMagSize)
			{
				hasJustReloaded = true;
				magAmmo = Reg.pistolMagSize;
				totalAmmo -= Reg.pistolMagSize;
			}
			else
				if (totalAmmo > 0)
				{
					hasJustReloaded = true;
					magAmmo = totalAmmo;
					totalAmmo = 0;
				}
		}
	}
	
	private function throwGrenade():Void
	{
		if (FlxG.keys.justPressed.E && grenadesAmmo > 0)
		{
			hasJustThrownGrenade = true;
			Weapon.directionToFace = facing;
			grenadesAmmo--;
		}
	}
	
	// Other Methods
	private function checkHitboxOffset():Void 
	{
		if (facing == FlxObject.LEFT)
			offset.x = 30;
		else
			offset.x = 10;
	}
	
	private function animationsSetUp():Void 
	{
		animation.add("idle", [0, 1, 2, 1], 6, true, false, false);
		animation.add("move", [3, 4, 5, 6, 7, 8, 9, 10], 12, true, false, false);
		animation.add("preJump", [11, 12], 24, false, false, false);
		animation.add("jump", [13], 16, false, false, false);
		animation.add("land", [14], 16, false, false, false);
		animation.add("crouch", [15, 16], 8, false, false, false);
		animation.add("stab", [17, 18, 19], 12, false, false, false);
		animation.add("crouchStab", [20, 21, 22], 12, false, false, false);
		animation.add("postCrouchStab", [16], 16, false, false, false);
		animation.add("aimUpwards", [23], 16, false, false, false);
		animation.add("shoot", [24, 25, 26], 12, false, false, false);
		animation.add("crouchShoot", [27, 28, 29], 12, false, false, false);
		animation.add("shootUpwards", [15, 30, 31, 32], 12, false, false, false);
		animation.add("reload", [33, 34, 35, 36, 37, 38, 39], 8, false, false, false);
		animation.add("throwGrenade", [40, 41, 42], 8, false, false, false);
		animation.add("crouchThrowGrenade", [43, 44, 45], 8, false, false, false);
		animation.add("die", [46, 47, 48, 49], 3, false, false, false);
	}
	
	private	function soundEffectsSetUp():Void
	{
		footStepSound = FlxG.sound.load(AssetPaths.footStep__wav);
		jumpSound = FlxG.sound.load(AssetPaths.jump__wav);
		knifeSlashSound = FlxG.sound.load(AssetPaths.knifeSlash__wav);
		pistolShotSound = FlxG.sound.load(AssetPaths.pistolShot__wav);
		pistolEmptyMagSound = FlxG.sound.load(AssetPaths.emptyMag__wav);
		pistolReloadSound = FlxG.sound.load(AssetPaths.pistolReload__wav);
		throwGrenadeSound = FlxG.sound.load(AssetPaths.throwGrenade__wav);
		pickUpCollectableSound = FlxG.sound.load(AssetPaths.pickUpCollectable__wav);
		powerUpSound = FlxG.sound.load(AssetPaths.powerUp__wav);
		deathSound = FlxG.sound.load(AssetPaths.playerDeath__wav);
	}
	override public function kill():Void
	{
		super.kill();
		
		Player.lives--;
		if (Player.lives > 0)
			reset(camera.scroll.x + 96, camera.scroll.y);
		else
			hasLost = true;
	}
	
	override public function reset(X, Y):Void
	{
		super.reset(X, Y);
		
		FlxFlicker.flicker(this, 3, 0.25, true, true, endSpawningInvincibility);
		knife.kill();
		hasJustShot = false;
		hasJustThrownGrenade = false;
		hasJustReloaded = false;
		height = Reg.playerStandingHeight;
		currentState = State.JUMPING;
	}
	
	private function endSpawningInvincibility(f:FlxFlicker):Void 
	{
		hasJustBeenHit = false;
	}
	
	public function getHit():Void
	{
		hasJustBeenHit = true;
	}
	
	private function launchBullet():Void 
	{
		if (!isAimingUpwards)
		{
			Weapon.directionToFace = facing;
			if (facing == FlxObject.LEFT)
			{
				var bullet = new Bullet(x - 4, y + 20, facing);
				pistolBullets.add(bullet);
			}
			else
			{
				var bullet = new Bullet(x + width, y + 20, facing);
				pistolBullets.add(bullet);
			}			
		}
		else
		{
			var bullet = new Bullet(x + width / 2, y, FlxObject.UP);
			pistolBullets.add(bullet);
		}
	}
	
	private function launchGrenade():Void 
	{
		if (facing == FlxObject.LEFT)
		{
			var grenade = new Grenade(x + 8, y, facing);
			grenades.add(grenade);
		}
		else
		{
			var grenade = new Grenade(x + width, y, facing);
			grenades.add(grenade);
		}
		
		hasJustThrownGrenade = false;
	}
	
	public function pickUpCollectable(collectable:Collectable)
	{
		switch (collectable.kindOfCollectable)
		{
			case 0:
				if (totalAmmo <= Reg.pistolMaxAmmo - Reg.pistolMagSize)
				{
					hasJustPickedUpCollectable = true;
					pickUpCollectableSound.play();
					totalAmmo += Reg.pistolMagSize;
				}
			case 1:
				if (Player.lives < 3)
				{
					hasJustPickedUpCollectable = true;
					pickUpCollectableSound.play();
					Player.lives++;
				}
			case 2:
				if (grenadesAmmo < 3)
				{
					hasJustPickedUpCollectable = true;
					pickUpCollectableSound.play();
					grenadesAmmo = Reg.maxGrenades;
				}
			case 3:
				if (!isInvincible)
				{
					hasJustPickedUpCollectable = true;
					powerUpSound.play();
					isInvincible = true;
					powerUpState.active = true;
					powerUpState.visible = true;
					invincibilityTime = Reg.invincibilityPowerUpTime;
					speed = Reg.playerPowerUpSpeed;
				}
			case 4:
				hasJustPickedUpCollectable = true;
				pickUpCollectable.play();s
				Reg.score += Reg.scoreCollectable;
		}
	}
	
	private function checkInvincibilty(time:Float)
	{
		if (isInvincible)
		{
			invincibilityTime -= time;
			if (invincibilityTime <= 0)
			{
				powerUpSound.play();
				isInvincible = false;
				powerUpState.active = false;
				powerUpState.visible = false;
				speed = Reg.playerNormalSpeed;
			}
		}
	}
	
	private	function checkDeathFromFalling():Void 
	{
		if (!isOnScreen())
		{
			invincibilityTime = 0;
			kill();
		}
	}
	
	// Getters & Setters	
	function get_pistolBullets():FlxTypedGroup<Bullet> 
	{
		return pistolBullets;
	}
	
	function get_grenades():FlxTypedGroup<Grenade> 
	{
		return grenades;
	}
	
	function get_hasJustBeenHit():Bool 
	{
		return hasJustBeenHit;
	}
	
	function get_totalAmmo():Int 
	{
		return totalAmmo;
	}
	
	static function get_lives():Int 
	{
		return lives;
	}
	
	function get_grenadesAmmo():Int 
	{
		return grenadesAmmo;
	}
	
	function get_knife():Knife 
	{
		return knife;
	}
	
	function get_hasLost():Bool 
	{
		return hasLost;
	}
	
	function get_hasJustPickedUpCollectable():Bool 
	{
		return hasJustPickedUpCollectable;
	}
	
	function set_hasJustPickedUpCollectable(value:Bool):Bool 
	{
		return hasJustPickedUpCollectable = value;
	}
	
	function get_isInvincible():Bool 
	{
		return isInvincible;
	}
	
	function get_currentState():State 
	{
		return currentState;
	}
}