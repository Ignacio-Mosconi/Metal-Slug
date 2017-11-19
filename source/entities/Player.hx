package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
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
}

class Player extends FlxSprite
{
	private var currentState:State;
	private var speed:Int;
	private var jumpSpeed:Int;
	private var knife:Knife;
	private var pistolBullets:FlxTypedGroup<Bullet>;
	private var grenades:FlxTypedGroup<Grenade>;
	private var hasJustShot:Bool;
	private var shootingCooldown:Float;
	private var isAimingUpwards:Bool;
	private var totalAmmo:Int;
	private var magAmmo:Int;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(AssetPaths.player__png, true, 80, 64, true);
		pixelPerfectPosition = false;
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
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
		
		width = 64;
		currentState = State.IDLE;
		speed = Reg.playerNormalSpeed;
		jumpSpeed = Reg.playerJumpSpeed;
		acceleration.y = Reg.gravity;
		hasJustShot = false;
		shootingCooldown = 0;
		isAimingUpwards = false;
		totalAmmo = 50;
		magAmmo = 7;

		knife = new Knife();
		knife.kill();
		FlxG.state.add(knife);
		
		pistolBullets = new FlxTypedGroup<Bullet>();
		FlxG.state.add(pistolBullets);
		grenades = new FlxTypedGroup<Grenade>();
		FlxG.state.add(grenades);
	}

	override public function update(elapsed:Float)
	{
		stateMachine(elapsed);
		checkHitboxOffset();
		
		trace(currentState);
		trace(magAmmo);
		trace(totalAmmo);
		
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

				if (velocity.x != 0)
					currentState = State.MOVING;
				else
				{
					if (knife.alive)
						currentState = State.STABBING;
					else
						if (height == Reg.playerCrouchedHeight)
							currentState = State.CROUCHED;
				}

			case State.MOVING:
				animation.play("move");
				move();
				jump();
				stab();
				shoot(elapsed);

				if (velocity.x == 0)
					currentState = State.IDLE;
				else
				{
					if (knife.alive)
						currentState = State.STABBING;
				}

			case State.PREJUMPING:
				if (animation.name != "preJump")
					animation.play("preJump");

				if (animation.name == "preJump" && animation.finished)
				{
					velocity.y = jumpSpeed;
					currentState = State.JUMPING;
				}

			case State.JUMPING:
				if (animation.name != "jump")
					animation.play("jump");

				stab();
				shoot(elapsed);

				if (velocity.y == 0)
					currentState = State.LANDING;
				else
				{
					if (knife.alive)
						currentState = State.STABBING;
				}

			case State.LANDING:
				if (animation.name != "land")
					animation.play("land");

				if (animation.name == "land" && animation.finished)
				{
					if (velocity.x == 0)
						currentState = State.IDLE;
					else
						currentState = State.MOVING;
				}

			case State.CROUCHED:
				if (animation.name != "crouch" && animation.name != "crouchStab" && animation.name != "crouchShoot")
				{
					if (animation.name != "postCrouchStab")
						animation.play("crouch");
				}
				else
					if (animation.name != "postCrouchStab")
						animation.play("postCrouchStab");
				stab();
				shoot(elapsed);

				if (!FlxG.keys.pressed.DOWN)
				{
					y -= 16;
					height = Reg.playerStandingHeight;
					offset.y = 0;
					currentState = State.IDLE;
				}
				else
				{
					if (knife.alive)
						currentState = State.STABBING;
				}

			case State.STABBING:
				if (height == Reg.playerStandingHeight)
				{
					if (animation.name != "stab")
						animation.play("stab");
				}
				else
					if (animation.name != "crouchStab")
						animation.play("crouchStab");

				if (velocity.y == 0)
					velocity.x = 0;
				knife.x = (facing == FlxObject.LEFT) ? x - knife.width: x + width;
				knife.y = y + height / 2 - knife.height / 2;

				if ((animation.name == "stab" || animation.name == "crouchStab") && animation.finished)
				{
					knife.kill();
					
					if (velocity.y != 0)
						currentState = State.JUMPING;
					else
					{
						if (velocity.x != 0)
							currentState = State.MOVING;
						else
						{
							if (height == Reg.playerCrouchedHeight)
								currentState = State.CROUCHED;
							else
								currentState = State.IDLE;
						}
					}
				}
				
			case State.AIMING_UPWARDS:
				animation.play("aimUpwards");
				
				stab();
				shoot(elapsed);
				
				if (!FlxG.keys.pressed.UP)
				{
					isAimingUpwards = false;
					currentState = State.IDLE;
				}
				else
					if (knife.alive)
					{
						isAimingUpwards = false;
						currentState = State.STABBING;
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
					&& animation.finished)
				{
					if (velocity.y != 0)
						currentState = State.JUMPING;
					else
					{
						if (velocity.x != 0)
							currentState = State.MOVING;
						else
						{
							if (height == Reg.playerCrouchedHeight)
								currentState = State.CROUCHED;
							else
							{
								if (isAimingUpwards)
									currentState = State.AIMING_UPWARDS;
								else
									currentState = State.IDLE;
							}
						}
					}
				}
				
			case State.RELOADING:
				if (animation.name != "reload")
					animation.play("reload");
				
				if (animation.name == "reload" && animation.finished)
					currentState = State.IDLE;
					
			case State.THROWING_GRENADE:
				if (animation.name != "throwGrenade")
					animation.play("throwGrenade");
					
				if (animation.name == "throwGrenade" && animation.finished)
					currentState = State.IDLE;
		}
	}

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
			currentState = State.PREJUMPING;
		}
	}

	private function crouch():Void
	{
		if (FlxG.keys.pressed.DOWN)
		{
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
		{
			isAimingUpwards = true;
			currentState = State.AIMING_UPWARDS;
		}
	}
	
	private function shoot(time:Float):Void
	{
		if (FlxG.keys.justPressed.A && !hasJustShot && magAmmo > 0)
		{
			currentState = State.SHOOTING;
			hasJustShot = true;
			shootingCooldown = 0;
			magAmmo--;
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
		else
		{
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
				currentState = State.RELOADING;
				magAmmo = Reg.pistolMagSize;
				totalAmmo -= Reg.pistolMagSize;
			}
			else
				if (totalAmmo > 0)
				{
					currentState = State.RELOADING;
					magAmmo = totalAmmo;
					totalAmmo = 0;
				}
		}
	}
	
	private function throwGrenade():Void
	{
		if (FlxG.keys.justPressed.E)
		{
			currentState = State.THROWING_GRENADE;
			Weapon.directionToFace = facing;
			if (facing == FlxObject.LEFT)
			{
				var grenade = new Grenade(x + 8, y);
				grenades.add(grenade);
			}
			else
			{
				var grenade = new Grenade(x + width, y);
				grenades.add(grenade);
			}
		}
	}
	
	private function checkHitboxOffset():Void 
	{
		if (facing == FlxObject.LEFT)
			offset.x = 16;
		else
			offset.x = 0;
	}
}