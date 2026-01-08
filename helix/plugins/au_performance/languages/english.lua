ix.Locale:Build("en")


option.gmod_mcore_test 					= "Multithreaded Processing"
option.gmod_mcore_test.desc 			= "Enables multithreaded processing for your game. Requires a restart."

option.mat_queue_mode 					= "Material Queue Mode"
option.mat_queue_mode.desc 				= "The queue/thread mode that the material system should use (-1 = default, 0 = synchronous single-threaded, 1 = queued single-threaded, 2 = queued multithreaded)."

option.cl_threaded_bone_setup 			= "Multithreaded Bone System"
option.cl_threaded_bone_setup.desc 		= "Enables parallel processing for the bone system."

option.r_decals 						= "Max Number of Decals"
option.r_decals.desc 					= "The maximum number of decals that can be displayed at the same time."

option.r_drawmodeldecals 				= "Draw Model Decals"
option.r_drawmodeldecals.desc 			= "Enable or disable the drawing of decals on models."

option.r_maxmodeldecal 					= "Max Model Decals"
option.r_maxmodeldecal.desc 			= "The maximum number of decals that can be displayed on models at the same time."

option.cl_ragdoll_collide 				= "Client Ragdoll Collision"
option.cl_ragdoll_collide.desc 			= "Enable or disable collisions for client models."

option.r_WaterDrawReflection 			= "Water Reflections"
option.r_WaterDrawReflection.desc 		= "Enable or disable reflections in water."

option.r_WaterDrawRefraction 			= "Water Refractions"
option.r_WaterDrawRefraction.desc 		= "Enable or disable refractions in water."

option.r_shadows 						= "Model Shadows"
option.r_shadows.desc 					= "Enable or disable shadows cast by models and objects."

option.mat_mipmaptextures 				= "'Mipmap' Textures"
option.mat_mipmaptextures.desc 			= "Improves texture quality at the expense of performance."

option.mat_filtertextures 				= "Texture Filtering"
option.mat_filtertextures.desc 			= "Improves texture quality at the expense of performance."

option.mat_envmapsize 					= "Environment Map Size"
option.mat_envmapsize.desc 				= "Adjusts the resolution of environment maps used for reflective surfaces."

option.cl_phys_props_enable 			= "Client Object Physics"
option.cl_phys_props_enable.desc 		= "Enables client-side physics for objects. Requires reconnection."

option.cl_ejectbrass 					= "Shell Ejection"
option.cl_ejectbrass.desc 				= "Enable or disable the ejection of shell casings from weapons when firing."

option.mat_filterlightmaps 				= "Lightmap Filtering"
option.mat_filterlightmaps.desc 		= "Improves lighting quality at the expense of performance."

option.muzzleflash_light 				= "Muzzle Flash Lighting"
option.muzzleflash_light.desc 			= "Enable or disable lighting from muzzle flashes on the player model."

option.props_break_max_pieces 			= "Max Number of Prop Fragments"
option.props_break_max_pieces.desc 		= "The maximum number of fragments from breakable props (-1 = default for the model)."

option.r_3dsky 							= "3D Skybox"
option.r_3dsky.desc 					= "Enable or disable rendering of 3D skyboxes."

option.r_maxdlights 					= "Maximum Dynamic Lights"
option.r_maxdlights.desc 				= "The maximum number of dynamic lights that can exist at the same time."

option.r_eyemove 						= "Eye Movement"
option.r_eyemove.desc 					= "Enable or disable eye movement for characters and NPCs."

option.r_eyes 							= "Eye Display"
option.r_eyes.desc 						= "Enable or disable the display of eyes for characters and NPCs."

option.r_teeth 							= "Teeth Display"
option.r_teeth.desc 					= "Enable or disable the display of teeth for characters and NPCs."

option.r_radiosity 						= "Radiosity Settings"
option.r_radiosity.desc 				= "Radiosity sampling method (0 = no radiosity, 1 = radiosity using environment cube (6 samples), 2 = radiosity with 162 samples, 3 = 162 samples for static objects, 6 samples for everything else)."

option.r_worldlights 					= "World Lighting"
option.r_worldlights.desc 				= "Number of world lights used per vertex."

option.rope_averagelight 				= "Average Lighting for Ropes"
option.rope_averagelight.desc 			= "Forces ropes to use average lighting from the cubemap instead of maximum intensity."

option.rope_collide 					= "Rope Collisions"
option.rope_collide.desc 				= "Enable or disable rope collisions with the world."

option.rope_rendersolid 				= "Rope Display"
option.rope_rendersolid.desc 			= "Enable or disable the display of ropes."

option.rope_smooth 						= "Rope Smoothing"
option.rope_smooth.desc 				= "Enable or disable rope smoothing."

option.rope_subdiv 						= "Rope Subdivision"
option.rope_subdiv.desc 				= "Number of sub-ropes."

option.violence_ablood 					= "Zombie/Alien Blood"
option.violence_ablood.desc 			= "Enable or disable the display of zombie/alien blood."

option.violence_agibs 					= "Zombie/Alien Gibs"
option.violence_agibs.desc 				= "Enable or disable the display of zombie/alien gibs."

option.violence_hblood 					= "Human Blood"
option.violence_hblood.desc 			= "Enable or disable the display of blood."

option.violence_hgibs 					= "Human Gibs"
option.violence_hgibs.desc 				= "Enable or disable the display of gibs."

option.ai_expression_optimization 		= "AI Expression Optimization"
option.ai_expression_optimization.desc 	= "Enable or disable NPC expressions when you can't see them."

option.cl_detaildist					= "Detail Distance"
option.cl_detaildist.desc 				= "Distance at which object details become invisible."

option.cl_detailfade 					= "Detail Fade"
option.cl_detailfade.desc 				= "Distance at which object details fade in smoothly."

option.r_fastzreject 					= "Fast Z-Reject"
option.r_fastzreject.desc 				= "Activates/deactivates fast Z-reject setting to take advantage of hardware with fast Z-reject. Use -1 to revert to default settings."

option.cl_show_splashes 				= "Water Splash Display"
option.cl_show_splashes.desc 			= "Enable or disable the display of water splashes."

option.r_drawflecks 					= "Fragment Display"
option.r_drawflecks.desc 				= "Enable or disable the creation of particles when shooting at walls."

option.r_threaded_particles 			= "Multithreaded Particle System"
option.r_threaded_particles.desc 		= "Enables parallel processing for the particle system."

option.snd_mix_async 					= "Multithreaded Sound System"
option.snd_mix_async.desc 				= "Enables parallel processing for the sound system."

option.r_threaded_renderables 			= "Multithreaded Rendering System"
option.r_threaded_renderables.desc 		= "Enables parallel processing for the rendering system."

option.cl_forcepreload 					= "Force Preload"
option.cl_forcepreload.desc 			= "Force preloads all content before loading the map, instead of loading as needed."