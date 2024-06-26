extends CharacterBody3D

@onready var revolver_sprite = $UI/Revolver/AnimatedSprite2D
@onready var sniper_sprite = $UI/Sniper/AnimatedSprite2D
@onready var shotgun_sprite = $UI/Shotgun/AnimatedSprite2D
@onready var boxing_sprite = $UI/Nothing/AnimatedSprite2D
@onready var face_profile = $UI/Bottom/BottomHUD/FaceProfile

@onready var revolver_audio = $Camera3D/Audio/RevolverAudio
@onready var shotgun_audio = $Camera3D/Audio/ShotgunAudio
@onready var sniper_audio = $Camera3D/Audio/SniperAudio
@onready var hurt_audio = $Camera3D/Audio/HurtAudio
@onready var death_audio = $Camera3D/Audio/DeathAudio

@onready var boxing_timer = $UI/Nothing/Timer

@onready var melee_anim = $MeleeRay/MeleeAnim
@onready var death_screen = $UI/DeathScreen
@onready var ray_cast_3d = $GunRayCast
@onready var interact_ray = $InteractRay
@onready var melee_ray = $MeleeRay
@onready var hud_weapon_sprite = $UI/Bottom/WeaponLabel/WeaponHUD
@onready var blood_particles = $MeleeRay/BloodParticles
@onready var melee_timer = $MeleeRay/MeleeTimer
@onready var camera_animation_player = $Camera3D/CameraAnimationPlayer
@onready var animation_player = $AnimationPlayer

@onready var melee_audio = $MeleeRay/MeleeAudioPlayer

@export var damage_power_P = 25
@export var melee_damage = 20

const SPEED = 5.0
const MOUSE_SENS = 0.2

var can_shoot = true
var can_punch = true
var dead = false
var health = 100
var current_weapon = "revolver"
var current_ammo = 12


func _ready():
	#camera_animation_player.play("face_movement")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$UI/DeathScreen/Panel/Button.button_up.connect(restart)


func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
	if dead:
		return
	if Input.is_action_just_pressed("Shoot") and current_ammo > 0:
		if current_weapon == "shotgun":
			shoot()
		else :
			shoot()
	if Input.is_action_just_pressed("show_health"):
		show_health()
	if Input.is_action_just_pressed("Melee attack"):
		meleeAttack()
	else:
		melee_anim.hide()


func _process(delta):
	if dead:
		death_audio.play()
		$UI/Bottom/HealthCounter.text = str(0)
	if Input.is_action_just_pressed("restart"):
		restart()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	#animation_player.play("face_movement")
	gun_switch()


#Movement code
func _physics_process(delta):
	if health > 100:
		health = 100
	if dead:
		return
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if current_ammo == 0:
		current_weapon = "nothing"
	animation_player.play("face_movement")
	kill()
	update_ammo_label()
	update_health_label()
	move_and_slide()


#restarts scene
func restart():
	get_tree().reload_current_scene()


func meleeAttack():
	if !can_punch:
		return
	can_punch = false
	if current_weapon != "nothing":
		melee_timer.start()
		melee_anim.show()
		melee_anim.play("attack")
		melee_audio.play()
		if melee_ray.is_colliding() and melee_ray.get_collider().has_method("_on_player_melee"):
			melee_ray.get_collider()._on_player_melee(melee_damage)
			blood_particles.emitting = true
			melee_ray.get_collider().kill()
	
	if current_weapon == "nothing":
		boxing_timer.start()


func shoot():
	if can_shoot and current_ammo >= 0:
		current_ammo -= 1
	if !can_shoot:
		return
	#if current_ammo <= -1:
		#return
	can_shoot = false
	if current_weapon == "revolver":
		$UI/Revolver/RevolverTimer.start()
		revolver_audio.play()
		revolver_sprite.play("revolver shoot")
	if current_weapon == "shotgun":
		$UI/Shotgun/ShotgunTimer.start()
		shotgun_audio.play()
		shotgun_sprite.play("shoot")
	
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("_on_player_damage") and current_ammo > 0:
		ray_cast_3d.get_collider()._on_player_damage(damage_power_P)
		ray_cast_3d.get_collider().kill()


func update_ammo_label():
	$UI/Bottom/AmmoCounter.text = str(current_ammo)
	if current_ammo <= 0:
		return
	#pass


#Updates health counter
func update_health_label():
	if dead:
		return
	$UI/Bottom/HealthCounter.text = str(health)


func gun_switch():
	if current_weapon == "revolver":
		revolver_sprite.show()
		shotgun_sprite.hide()
		sniper_sprite.hide()
		hud_weapon_sprite.play("Revolver")
	
	if current_weapon == "shotgun":
		shotgun_sprite.show()
		revolver_sprite.hide()
		sniper_sprite.hide()
		hud_weapon_sprite.play("Shotgun")
	
	if current_weapon == "sniper":
		sniper_sprite.show()
		revolver_sprite.hide()
		shotgun_sprite.hide()
		hud_weapon_sprite.play("Sniper")
	
	if current_weapon == "nothing":
		sniper_sprite.hide()
		revolver_sprite.hide()
		shotgun_sprite.hide()
		boxing_sprite.show()


#Dies when health reaches zero
func kill():
	if health <= 0:
		#death_audio.play()
		dead = true
		death_screen.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


#Shows health in console
func show_health():
	print(health)
	print(current_weapon)
	print(damage_power_P)
	print(can_shoot)


####################
# Signal Functions #
####################

func Hit_Succesfull(projectile_damage):
	if dead:
		return
	health -= projectile_damage
	hurt_audio.play()
	camera_animation_player.play("pain")
	face_profile.play("anger")
	#print("hurt")
	$UI/Bottom/BottomHUD/FaceProfile/FaceTimer.start()

#Takes damage when colliding with enemy
func _on_enemy_damage(damage_power):
	if dead:
		return
	health -= damage_power
	hurt_audio.play()
	camera_animation_player.play("pain")
	face_profile.play("anger")
	$UI/Bottom/BottomHUD/FaceProfile/FaceTimer.start()


#Heals when interacting with medkit
func _on_med_kit_heal(heal_amount):
	if health >= 100:
		return
	health += heal_amount


func Weapon_damage(damage_num):
	damage_power_P = damage_num

func Weapon_name(weapon_name):
	current_weapon = weapon_name

func ammo_refill(ammo_amount):
	current_ammo = ammo_amount
#########################
#   Shotgun signals    #
#########################

#Changes the "can shoot var to true when using shotgun
func _on_shotgun_timer_timeout():
	#pass
	can_shoot = true


#########################
#   Sniper signals      #
#########################

func _on_melee_timer_timeout():
	can_punch = true


#########################
#   Revolver signals    #
#########################

func _on_revolver_timer_timeout():
	can_shoot = true


func _on_face_timer_timeout():
	face_profile.play("normal")
