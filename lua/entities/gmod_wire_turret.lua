AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Turret"
ENT.WireDebugName 	= "Turret"

if CLIENT then return end -- No more client

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Firing 	= false
	self.NextShot 	= 0

	self.Inputs = Wire_CreateInputs(self, { "Fire" })
end

function ENT:FireShot()

	if ( self.NextShot > CurTime() ) then return end

	self.NextShot = CurTime() + self.delay

	-- Make a sound if you want to.
	if self.sound then
		self:EmitSound(self.sound)
	end

	-- Get the muzzle attachment (this is pretty much always 1)
	local Attachment = self:GetAttachment( 1 )

	-- Get the shot angles and stuff.
	local shootOrigin = Attachment.Pos
	local shootAngles = self:GetAngles()

	-- Shoot a bullet
	local bullet = {}
		bullet.Num 			= self.numbullets
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootAngles:Forward()
		bullet.Spread 		= self.spread
		bullet.Tracer		= self.tracernum
		bullet.TracerName 	= self.tracer
		bullet.Force		= self.force
		bullet.Damage		= self.damage
		bullet.Attacker 	= self:GetPlayer()
	self:FireBullets( bullet )

	-- Make a muzzle flash
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( shootAngles )
		effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )

end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:Think()
	self.BaseClass.Think(self)

	if( self.Firing ) then
		self:FireShot()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:TriggerInput(iname, value)
	if (iname == "Fire") then
		self.Firing = value > 0
	end
end

local ValidTracers = {
	["Tracer"]=true,
	["AR2Tracer"]=true,
	["AirboatGunHeavyTracer"]=true,
	["LaserTracer"]=true,
	[""]=true,
}

function ENT:Setup(delay, damage, force, sound, numbullets, spread, tracer, tracernum)
	self.delay = delay
	self.damage = damage
	self.force = force
	-- Preventing client crashes
	if string.find(sound, '["?]') then
		self.sound = ""
	else
		self.sound = sound
	end
	self.numbullets = numbullets
	self.spread = Vector(spread, spread, 0)

	self.tracer = ValidTracers[string.Trim(tracer)] and string.Trim(tracer) or ""
	self.tracernum = tracernum or 1
end

duplicator.RegisterEntityClass( "gmod_wire_turret", WireLib.MakeWireEnt, "Data", "delay", "damage", "force", "sound", "numbullets", "spread", "tracer", "tracernum" )
