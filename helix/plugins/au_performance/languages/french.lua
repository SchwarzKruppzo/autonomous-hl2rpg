ix.Locale:Build("fr")


option.gmod_mcore_test 					= "Traitement multithread"
option.gmod_mcore_test.desc 			= "Active le traitement multithread pour votre jeu. Nécessite un redémarrage."

option.mat_queue_mode 					= "Mode de file d'attente des matériaux"
option.mat_queue_mode.desc 				= "Le mode de file/thread que le système de matériaux doit utiliser (-1 = par défaut, 0 = synchrone single-thread, 1 = en file single-thread, 2 = en file multithread)."

option.cl_threaded_bone_setup 			= "Système d'os multithread"
option.cl_threaded_bone_setup.desc 		= "Active le traitement parallèle pour le système d'os."

option.r_decals 						= "Nombre max de décalcomanies"
option.r_decals.desc 					= "Le nombre maximum de décalcomanies pouvant être affichées en même temps."

option.r_drawmodeldecals 				= "Décalcomanies sur les modèles"
option.r_drawmodeldecals.desc 			= "Activer ou désactiver l'affichage des décalcomanies sur les modèles."

option.r_maxmodeldecal 					= "Décalcomanies max sur les modèles"
option.r_maxmodeldecal.desc 			= "Le nombre maximum de décalcomanies pouvant être affichées sur les modèles en même temps."

option.cl_ragdoll_collide 				= "Collision des ragdolls côté client"
option.cl_ragdoll_collide.desc 			= "Activer ou désactiver les collisions pour les modèles clients."

option.r_WaterDrawReflection 			= "Reflets dans l'eau"
option.r_WaterDrawReflection.desc 		= "Activer ou désactiver les reflets dans l'eau."

option.r_WaterDrawRefraction 			= "Réfractions dans l'eau"
option.r_WaterDrawRefraction.desc 		= "Activer ou désactiver les réfractions dans l'eau."

option.r_shadows 						= "Ombres des modèles"
option.r_shadows.desc 					= "Activer ou désactiver les ombres projetées par les modèles et objets."

option.mat_mipmaptextures 				= "Textures 'Mipmap'"
option.mat_mipmaptextures.desc 			= "Améliore la qualité des textures au détriment des performances."

option.mat_filtertextures 				= "Filtrage des textures"
option.mat_filtertextures.desc 			= "Améliore la qualité des textures au détriment des performances."

option.mat_envmapsize 					= "Taille de la carte d'environnement"
option.mat_envmapsize.desc 				= "Ajuste la résolution des cartes d'environnement utilisées pour les surfaces réfléchissantes."

option.cl_phys_props_enable 			= "Physique des objets côté client"
option.cl_phys_props_enable.desc 		= "Active la physique côté client pour les objets. Nécessite une reconnexion."

option.cl_ejectbrass 					= "Éjection des douilles"
option.cl_ejectbrass.desc 				= "Activer ou désactiver l'éjection des douilles des armes lors du tir."

option.mat_filterlightmaps 				= "Filtrage des lightmaps"
option.mat_filterlightmaps.desc 		= "Améliore la qualité de l'éclairage au détriment des performances."

option.muzzleflash_light 				= "Éclairage du flash de bouche"
option.muzzleflash_light.desc 			= "Activer ou désactiver l'éclairage du flash de bouche sur le modèle du joueur."

option.props_break_max_pieces 			= "Nombre max de fragments de props"
option.props_break_max_pieces.desc 		= "Le nombre maximum de fragments des props destructibles (-1 = par défaut pour le modèle)."

option.r_3dsky 							= "Skybox 3D"
option.r_3dsky.desc 					= "Activer ou désactiver le rendu des skyboxes 3D."

option.r_maxdlights 					= "Lumières dynamiques maximum"
option.r_maxdlights.desc 				= "Le nombre maximum de lumières dynamiques pouvant exister en même temps."

option.r_eyemove 						= "Mouvement des yeux"
option.r_eyemove.desc 					= "Activer ou désactiver le mouvement des yeux pour les personnages et PNJ."

option.r_eyes 							= "Affichage des yeux"
option.r_eyes.desc 						= "Activer ou désactiver l'affichage des yeux pour les personnages et PNJ."

option.r_teeth 							= "Affichage des dents"
option.r_teeth.desc 					= "Activer ou désactiver l'affichage des dents pour les personnages et PNJ."

option.r_radiosity 						= "Paramètres de radiosité"
option.r_radiosity.desc 				= "Méthode d'échantillonnage de la radiosité (0 = pas de radiosité, 1 = radiosité avec cube d'environnement (6 échantillons), 2 = radiosité avec 162 échantillons, 3 = 162 échantillons pour objets statiques, 6 échantillons pour le reste)."

option.r_worldlights 					= "Éclairage du monde"
option.r_worldlights.desc 				= "Nombre de lumières du monde utilisées par sommet."

option.rope_averagelight 				= "Éclairage moyen pour les cordes"
option.rope_averagelight.desc 			= "Force les cordes à utiliser l'éclairage moyen de la cubemap au lieu de l'intensité maximale."

option.rope_collide 					= "Collisions des cordes"
option.rope_collide.desc 				= "Activer ou désactiver les collisions des cordes avec le monde."

option.rope_rendersolid 				= "Affichage des cordes"
option.rope_rendersolid.desc 			= "Activer ou désactiver l'affichage des cordes."

option.rope_smooth 						= "Lissage des cordes"
option.rope_smooth.desc 				= "Activer ou désactiver le lissage des cordes."

option.rope_subdiv 						= "Subdivision des cordes"
option.rope_subdiv.desc 				= "Nombre de sous-cordes."

option.violence_ablood 					= "Sang zombie/alien"
option.violence_ablood.desc 			= "Activer ou désactiver l'affichage du sang zombie/alien."

option.violence_agibs 					= "Gibs zombie/alien"
option.violence_agibs.desc 				= "Activer ou désactiver l'affichage des gibs zombie/alien."

option.violence_hblood 					= "Sang humain"
option.violence_hblood.desc 			= "Activer ou désactiver l'affichage du sang."

option.violence_hgibs 					= "Gibs humains"
option.violence_hgibs.desc 				= "Activer ou désactiver l'affichage des gibs."

option.ai_expression_optimization 		= "Optimisation des expressions IA"
option.ai_expression_optimization.desc 	= "Activer ou désactiver les expressions des PNJ quand vous ne pouvez pas les voir."

option.cl_detaildist					= "Distance des détails"
option.cl_detaildist.desc 				= "Distance à laquelle les détails des objets deviennent invisibles."

option.cl_detailfade 					= "Fondu des détails"
option.cl_detailfade.desc 				= "Distance à laquelle les détails des objets apparaissent en douceur."

option.r_fastzreject 					= "Rejet Z rapide"
option.r_fastzreject.desc 				= "Active/désactive le paramètre de rejet Z rapide pour profiter du matériel avec rejet Z rapide. Utilisez -1 pour revenir aux paramètres par défaut."

option.cl_show_splashes 				= "Affichage des éclaboussures d'eau"
option.cl_show_splashes.desc 			= "Activer ou désactiver l'affichage des éclaboussures d'eau."

option.r_drawflecks 					= "Affichage des fragments"
option.r_drawflecks.desc 				= "Activer ou désactiver la création de particules lors des tirs sur les murs."

option.r_threaded_particles 			= "Système de particules multithread"
option.r_threaded_particles.desc 		= "Active le traitement parallèle pour le système de particules."

option.snd_mix_async 					= "Système sonore multithread"
option.snd_mix_async.desc 				= "Active le traitement parallèle pour le système sonore."

option.r_threaded_renderables 			= "Système de rendu multithread"
option.r_threaded_renderables.desc 		= "Active le traitement parallèle pour le système de rendu."

option.cl_forcepreload 					= "Préchargement forcé"
option.cl_forcepreload.desc 			= "Force le préchargement de tout le contenu avant le chargement de la carte, au lieu de charger à la demande."
