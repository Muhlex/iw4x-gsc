#include scripts\_utility;

// This script provides global callbacks for various events not possible without replacing
// stock functions. This can lead to compatibility issues if another mod decides to replace
// the same functions listed here. Use the `subscribe` function to access these callbacks.

init()
{
	if (isDefined(level._overrides)) return;

	level._overrides = spawnStruct();
	level._overrides.callbacks = [];
	replaceFunc(maps\mp\gametypes\_damage::finishPlayerDamageWrapper, ::finishPlayerDamageWrapper);
}

subscribe(id, func)
{
	init();

	callbacks = level._overrides.callbacks;

	if (!isDefined(callbacks[id]))
		callbacks[id] = [];
	callbacks[id][callbacks[id].size] = func;

	level._overrides.callbacks = callbacks;
}

runCallbacks(id, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
{
	callbacks = level._overrides.callbacks;
	if (!isDefined(callbacks[id])) return;

	foreach (func in callbacks[id])
		self callFunc(func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16);
}

finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction)
{
	// ### MODIFICATION START ###
	self runCallbacks("finishPlayerDamage", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction);
	// ### MODIFICATION END ###

	if ( (self maps\mp\_utility::isUsingRemote() ) && (iDamage >= self.health) && !(iDFlags & level.iDFLAGS_STUN) )
	{
		if ( !isDefined( vDir ) )
			vDir = ( 0,0,0 );

		if ( !isDefined( eAttacker ) && !isDefined( eInflictor ) )
		{
			eAttacker = self;
			eInflictor = eAttacker;
		}

		assert( isDefined( eAttacker ) );
		assert( isDefined( eInflictor ) );

		maps\mp\gametypes\_damage::PlayerKilled_internal( eInflictor, eAttacker, self, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, 0, true );
	}
	else
	{
		if ( !self maps\mp\gametypes\_damage::Callback_KillingBlow( eInflictor, eAttacker, iDamage - (iDamage * stunFraction), iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ) )
			return;

		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
	}

	if ( sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" )
		self shellShock( "damage_mp", getDvarFloat( "scr_csmode" ) );

	self maps\mp\gametypes\_damage::damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage, iDFlags, eAttacker );
}
