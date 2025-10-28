ix.ForcefieldModes = {
	{
		Name = "1",
		Skin = 0,
		Condition = function ( pPlayer )
			local bCombine = pPlayer:IsCombine()

			return (not bCombine and (pPlayer.hasWeapons == true))
		end
	},
	{
		Name = "2",
		Skin = 0,

		Condition = function ( pPlayer )
			local bCombine = pPlayer:IsCombine()
			return not bCombine
		end
	},
	{
		Name = "3",
		Skin = 1,
		Condition = function ( pPlayer )
			return false
		end
	}
}


AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Combine Forcefield"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunPickupDisabled = true
ENT.IsForcefield = true

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Mode" )
	self:NetworkVar( "Bool", 0, "Broken" )
	self:NetworkVar( "Entity", 0, "Dummy" )
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_combine/combine_fence01b.mdl")
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PhysicsInit( SOLID_VPHYSICS )

		local tData = {}
		tData.start = self:GetPos() + self:GetRight() * -16
		tData.endpos = self:GetPos() + self:GetRight() * -600
		tData.filter = self

		local trData = util.TraceLine( tData )

		local aAngles = self:GetAngles()
		aAngles:RotateAroundAxis( aAngles:Up(), 90 )

		self.eRightSide = ents.Create( "prop_physics" )
		self.eRightSide:SetModel("models/props_combine/combine_fence01a.mdl")
		self.eRightSide:SetPos( trData.HitPos )
		self.eRightSide:SetAngles( self:GetAngles() )
		self.eRightSide:Spawn()
		self.eRightSide.PhysgunPickupDisabled = true
		self.eRightSide:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self.eRightSide:DrawShadow(false)
		self:DeleteOnRemove( self.eRightSide )

		local tVerts = {
			{ pos = Vector( 0, 0, -40 ) },
			{ pos = Vector( 0, 0, 150 ) },
			{ pos = self:WorldToLocal( self.eRightSide:GetPos() ) + Vector( 0, 0, 150 ) },
			{ pos = self:WorldToLocal( self.eRightSide:GetPos() ) + Vector( 0, 0, 150 ) },
			{ pos = self:WorldToLocal( self.eRightSide:GetPos() ) - Vector( 0, 0, 25 ) },
			{ pos = Vector( 0, 0, -40 ) }
		}

		//self:AddSolidFlags(FSOLID_FORCE_WORLD_ALIGNED)
    	self:AddFlags(FL_STATICPROP)

		self:PhysicsFromMesh( tVerts )

		local physObj = self:GetPhysicsObject()
		if IsValid( physObj ) then
			physObj:EnableMotion( false )
			physObj:Sleep()
		end

		self:SetCustomCollisionCheck( true )
		self:EnableCustomCollisions( true )

		physObj = self.eRightSide:GetPhysicsObject()
		if IsValid( physObj ) then
			physObj:EnableMotion( false )
			physObj:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
        	physObj:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
		end

		self.eRightSide:MakePhysicsObjectAShadow()
		self:SetDummy( self.eRightSide )

		self:SetHealth( 4000 )
		self:SetForcefield( 1 )

		-- This is broke but not currently fussed.
		self.ShieldLoop = CreateSound( self, "ambient/machines/combine_shield_touch_loop1.wav" )
	else
		local tData = {}
		tData.start = self:GetPos() + self:GetRight() * -16
		tData.endpos = self:GetPos() + self:GetRight() * -480
		tData.filter = self

		local trData = util.TraceLine( tData )
	
		self:PhysicsInitConvex({
			vector_origin,
			Vector( 0, 0, 150 ),
			trData.HitPos + Vector( 0, 0, 150 ),
			trData.HitPos
		})
		self:EnableCustomCollisions( true )

		self.eRightSide = self:GetDummy()
		self.eRightSide.IsForcefield = true
	end
end

function ENT:OnTakeDamage( damage )
	if self:Health() <= 0 then return end

	if not self.applyingDamage then
		self.applyingDamage = true

		local pAttacker = damage:GetAttacker()
		if not IsValid( pAttacker ) then return end

		local nNewHealth = self:Health() - damage:GetDamage()

		self.eRightSide:EmitSound( "combine_tech/forcefield/spark_sparkles_" .. math.random( 1, 14 ) .. ".mp3" )

		if nNewHealth <= 0 then
			self:SetMode(3) 
			self:SetBroken(true)
	
			self.eRightSide:EmitSound( "combine_tech/forcefield/power_surge_" .. math.random( 1, 4 ) .. ".mp3" )
		end

		self:SetHealth( nNewHealth )

		self.applyingDamage = false
	end
end

function ENT:SetForcefield( iMode )
	if not IsValid( self.eRightSide ) or not IsValid( self ) then return end
	if iMode > #ix.ForcefieldModes then
		iMode = 1
	end

	local tNewMode = ix.ForcefieldModes[ iMode ]
	if not tNewMode then return end

	self:SetSkin( tNewMode.Skin )
	self.eRightSide:SetSkin( tNewMode.Skin )

	self:SetMode( iMode ) 
	self:CollisionRulesChanged()

	if iMode == 4 then
		self:EmitSound( "combine_tech/forcefield/shield_shutdown.mp3" )
	end
end

function ENT:Think()
	if not SERVER then return end

	if IsValid( self ) then
		self.ShieldLoop:Play()
		self.ShieldLoop:ChangeVolume( 0.4, 0 )
	else
		self.ShieldLoop:Stop()
	end
end

function ENT:Use( pPlayer )

	if self:GetBroken() then return end
	if ( self.iNextUse or 0 ) > CurTime() then return end
	
	self.iNextUse = CurTime() + 2.05

	if not self:HasPermissions( pPlayer ) then
		pPlayer:EmitSound( "combine_tech/forcefield/shield_touch" .. math.random( 1, 3 ) .. ".mp3", 70, 100, 0.2 )

		return
	end


	self:SetForcefield( self:GetMode() + 1 )

	if self:GetMode() == 3 then
		self:EmitSound( "combine_tech/forcefield/shield_shutdown2.mp3", 70, 100 )
	elseif self:GetMode() == 1 then
		self:EmitSound( "combine_tech/forcefield/shield_startup.mp3", 70, 100 )
	else
		self:EmitSound( "buttons/combine_button5.wav", 70, 100 + ( self:GetMode() - 1 ) * 15 )
	end

	pPlayer:ForceSequence( "harassfront1" )

	local tCurrentMode = ix.ForcefieldModes[ self:GetMode() ]
	//pPlayer:AddCombineNotification( L( "entities.forcefields.modeChanged", tCurrentMode.Name ), cTextColor, 7 )
end

function ENT:HasPermissions( pPlayer )
	//local tJobTable = pPlayer:GetJob()
	//if not tJobTable then return false end

	return false //pPlayer:IsCombine() //and tJobTable and ( tJobTable.forcefieldPerms or tJobTable.elevatedPerms ) or pPlayer:Team() == TEAM_ADMIN or false
end

function ENT:OnRemove()
	if SERVER then
		if self.ShieldLoop then
			self.ShieldLoop:Stop()
			self.ShieldLoop = nil
		end

		if IsValid( self.eRightSide ) then
			SafeRemoveEntity( self.eRightSide )
		end
	end
end

if SERVER then
	util.AddNetworkString("forcefield.weapon")

	net.Receive("forcefield.weapon", function(_, client)
		local hasWeapons

		for k, v in pairs(client:GetItems()) do
			if v.isWeapon then
				hasWeapons = true
				break
			end
		end

		client.hasWeapons = hasWeapons
		client:CollisionRulesChanged()
	end)

	function ENT:SpawnFunction( pPlayer, trData )
		local aAngles = ( pPlayer:GetPos() - trData.HitPos ):Angle()
		aAngles.p = 0
		aAngles.r = 0
		aAngles:RotateAroundAxis( aAngles:Up(), 270 )
	
		local eEntity = ents.Create( "ent_cmb_forcefield" )
		eEntity:SetPos( trData.HitPos + Vector( 0, 0, 40 ) )
		eEntity:SetAngles( aAngles:SnapTo( "y", 90 ) )
		eEntity:Spawn()
		eEntity:Activate()
	
		return eEntity
	end

	function ENT:StartTouch( eEntity )
		if self.ShieldLoop then
			self.ShieldLoop:Play()
			self.ShieldLoop:ChangeVolume( 1, 0.5 )
		end

		self.iEntitiesTouching = ( self.iEntitiesTouching or 0 ) + 1
	end

	function ENT:EndTouch( eEntity )
		self.iEntitiesTouching = math.max( ( self.iEntitiesTouching or 0 ) - 1, 0 )
		if self.iEntitiesTouching == 0 then
			self.ShieldLoop:FadeOut( 0.5 )
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	
	function ENT:DrawShield( vVertex )
		mesh.Begin( MATERIAL_QUADS, 1 )
			mesh.Position( vector_origin )
			mesh.TexCoord( 0, 0, 0 )
			mesh.AdvanceVertex()
	
			mesh.Position( self:GetUp() * 190 )
			mesh.TexCoord( 0, 0, 3 )
			mesh.AdvanceVertex()
	
			mesh.Position( vVertex + self:GetUp() * 190 )
			mesh.TexCoord( 0, 3, 3 )
			mesh.AdvanceVertex()
	
			mesh.Position( vVertex )
			mesh.TexCoord( 0, 3, 0 )
			mesh.AdvanceVertex()
		mesh.End()
	end


	local mat = Material( "models/hlvr/tad/alyx_fence/combine_shield_blue" )

	hook.Add("InitializedPlugins", "AddForcefieldCallback", function()
		ix.EntityDraw:AddCachedDrawCallback("PostDrawTranslucentRenderables", "ent_cmb_forcefield", 340000, function( eEntity )
			-- If the forcefield is broken, don't do any of this.
			if eEntity:GetMode() == 3 then return end
		
			local tCurrentMode = ix.ForcefieldModes[ eEntity:GetMode() ]
			if not tCurrentMode then return end
		
			local aAngles = eEntity:GetAngles()
			local mMatrix = Matrix()
			mMatrix:Translate( eEntity:GetPos() + eEntity:GetUp() * -40 )
			mMatrix:Rotate( aAngles )
		
			render.SetMaterial( mat )

			if not IsValid( eEntity.eRightSide ) then return end

			local vVertex = eEntity:WorldToLocal( eEntity.eRightSide:GetPos() )
			eEntity:SetRenderBounds( vector_origin, vVertex + eEntity:GetUp() * 150 )
		
			cam.PushModelMatrix( mMatrix )
				eEntity:DrawShield( vVertex )
			cam.PopModelMatrix()
			
			mMatrix:Translate( vVertex )
			mMatrix:Rotate( Angle(0, 180, 0) )
		
			cam.PushModelMatrix( mMatrix )
				eEntity:DrawShield( vVertex )
			cam.PopModelMatrix()
		end )
	end )
end