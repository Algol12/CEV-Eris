// Ported from Haine and WrongEnd with much gratitude!
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=WHAT-EVER=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/effect/wingrille_spawn
	name = "window grille spawner"
	icon = 'icons/obj/structures.dmi'
	icon_state = "wingrille"
	density = 1
	anchored = 1.0
	var/win_path = /obj/structure/window/basic
	var/activated

// stops ZAS expanding zones past us, the windows will block the zone anyway
/obj/effect/wingrille_spawn/CanPass()
	return 0

/obj/effect/wingrille_spawn/attack_hand()
	attack_generic()

/obj/effect/wingrille_spawn/attack_ghost()
	attack_generic()

/obj/effect/wingrille_spawn/attack_generic()
	activate()

/obj/effect/wingrille_spawn/Initialize()
	..()
	if(!win_path)
		return
	if(ticker && ticker.current_state < GAME_STATE_PLAYING)
		activate()

/obj/effect/wingrille_spawn/proc/activate()
	if(activated) return
	if (!locate(/obj/structure/grille) in get_turf(src))
		var/obj/structure/grille/G = PoolOrNew(/obj/structure/grille, src.loc)
		handle_grille_spawn(G)
	var/list/neighbours = list()
	for (var/dir in cardinal)
		var/turf/T = get_step(src, dir)
		var/obj/effect/wingrille_spawn/other = locate(/obj/effect/wingrille_spawn) in T
		if(!other)
			var/found_connection
			if(locate(/obj/structure/grille) in T)
				for(var/obj/structure/window/W in T)
					if(W.type == win_path && W.dir == get_dir(T,src))
						found_connection = 1
						qdel(W)
			if(!found_connection)
				var/obj/structure/window/new_win = PoolOrNew(win_path, src.loc)
				new_win.set_dir(dir)
				handle_window_spawn(new_win)
		else
			neighbours |= other
	activated = 1
	for(var/obj/effect/wingrille_spawn/other in neighbours)
		if(!other.activated) other.activate()
	qdel(src)

/obj/effect/wingrille_spawn/proc/handle_window_spawn(var/obj/structure/window/W)
	return

// Currently unused, could be useful for pre-wired electrified windows.
/obj/effect/wingrille_spawn/proc/handle_grille_spawn(var/obj/structure/grille/G)
	return

/obj/effect/wingrille_spawn/reinforced
	name = "reinforced window grille spawner"
	icon_state = "r-wingrille"
	win_path = /obj/structure/window/reinforced

/obj/effect/wingrille_spawn/reinforced/crescent
	name = "Crescent window grille spawner"
	win_path = /obj/structure/window/reinforced/crescent

/obj/effect/wingrille_spawn/plasma
	name = "plasma window grille spawner"
	icon_state = "p-wingrille"
	win_path = /obj/structure/window/plasmabasic

/obj/effect/wingrille_spawn/reinforced_plasma
	name = "reinforced plasma window grille spawner"
	icon_state = "pr-wingrille"
	win_path = /obj/structure/window/reinforced/plasma

/obj/effect/wingrille_spawn/reinforced/polarized
	name = "polarized window grille spawner"
	color = "#444444"
	win_path = /obj/structure/window/reinforced/polarized
	var/id

/obj/effect/wingrille_spawn/reinforced/polarized/handle_window_spawn(var/obj/structure/window/reinforced/polarized/P)
	if(id)
		P.id = id
