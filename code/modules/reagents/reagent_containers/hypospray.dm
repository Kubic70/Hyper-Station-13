/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list()
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/ignore_flags = 0
	var/infinite = FALSE

/obj/item/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(!iscarbon(M))
		return

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to inject", src, "([contained])")

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [M] with [src].</span>")

		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>")


			log_combat(user, M, "injected", src, "([contained])")

/obj/item/reagent_containers/hypospray/CMO
	list_reagents = list("omnizine" = 30)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list("epinephrine" = 30, "omnizine" = 30, "leporazine" = 15, "atropine" = 15)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with experimental medical compounds for rapid healing."
	volume = 100
	list_reagents = list("quantum_heal" = 80, "synaptizine" = 20)

/obj/item/reagent_containers/hypospray/magillitis
	name = "experimental autoinjector"
	desc = "A modified air-needle autoinjector with a small single-use reservoir. It contains an experimental serum."
	icon_state = "combat_hypo"
	volume = 5
	reagent_flags = NONE
	list_reagents = list("magillitis" = 5)

//MediPens

/obj/item/reagent_containers/hypospray/medipen
	name = "epinephrine medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge. Also useful for preventing organ decay in the deceased."
	icon_state = "medipen"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 11
	volume = 11
	ignore_flags = 1 //so you can medipen through hardsuits
	reagent_flags = DRAWABLE
	flags_1 = null
	list_reagents = list("epinephrine" = 10, "formaldehyde" = 1)

/obj/item/reagent_containers/hypospray/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to choke on \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/hypospray/medipen/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	..()
	if(!iscyborg(user))
		reagents.maximum_volume = 0 //Makes them useless afterwards
		reagent_flags = NONE
	update_icon()
	addtimer(CALLBACK(src, .proc/cyborg_recharge, user), 80)

/obj/item/reagent_containers/hypospray/medipen/proc/cyborg_recharge(mob/living/silicon/robot/user)
	if(!reagents.total_volume && iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.use(100))
			reagents.add_reagent_list(list_reagents)
			update_icon()

/obj/item/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/medipen/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "<span class='notice'>It is currently loaded.</span>"
	else
		. += "<span class='notice'>It is spent.</span>"

/obj/item/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("ephedrine" = 10, "coffee" = 10)

/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list("stimulants" = 10, "omnizine" = 10)

/obj/item/reagent_containers/hypospray/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	list_reagents = list("morphine" = 10)

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "stimpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list("atropine" = 10, "epinephrine" = 10, "salbutamol" = 20, "spaceacillin" = 20)

/obj/item/reagent_containers/hypospray/medipen/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. WARNING: Do not inject more than one pen in quick succession."
	icon_state = "stimpen"
	volume = 52
	amount_per_transfer_from_this = 52
	list_reagents = list("salbutamol" = 10, "leporazine" = 15, "neo_jelly" = 15, "epinephrine" = 10, "lavaland_extract" = 2)

/obj/item/reagent_containers/hypospray/medipen/species_mutator
	name = "species mutator medipen"
	desc = "Embark on a whirlwind tour of racial insensitivity by \
		literally appropriating other races."
	volume = 1
	amount_per_transfer_from_this = 1
	list_reagents = list("unstablemutationtoxin" = 1)

/obj/item/reagent_containers/hypospray/medipen/firelocker
	name = "fire treatment medipen"
	desc = "A medipen that has been fulled with burn healing chemicals for personnel without advanced medical knowledge."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list("oxandrolone" = 5, "kelotane" = 10)

/obj/item/reagent_containers/hypospray/combat/heresypurge
	name = "holy water autoinjector"
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with 5 doses of a holy water mixture."
	volume = 250
	list_reagents = list("holywater" = 150, "tiresolution" = 50, "dizzysolution" = 50)
	amount_per_transfer_from_this = 50

//Chemlight was here.

/obj/item/reagent_containers/hypospray/debug
	name = "retractable hypospray syringe"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 200
	possible_transfer_amounts = list()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	reagent_flags = OPENCONTAINER | NO_REACT
	slot_flags = ITEM_SLOT_BELT
	infinite = TRUE
	var/list/fun_ids = list("growthchem", "shrinkchem", "aphro", "aphro+", "penis_enlarger", "breast_enlarger", "space_drugs", "lithium")

/obj/item/reagent_containers/hypospray/debug/attack_self(mob/user)
	var/chosen_reagent
	var/list/reagent_ids = sortList(GLOB.chemical_reagents_list)
	var/quick_select = input(user, "Select an option", "Press start") in list("Quick menu", "Debug", "Cancel")
	switch (quick_select)
		if("Quick menu")
			var/list_selection = input(user, "Choose an catagory", "List Choice") in list("Emergency Meds", "Fun Chemicals", "Self Defense", "Cancel")
			switch(list_selection)
				if("Emergency Meds")
					reagents.clear_reagents()
					amount_per_transfer_from_this = 10
						reagents.add_reagent_list(list("atropine" = 10, "oxandrolone" = 20, "sal_acid" = 20, "salbutamol" = 10))

				if("Self Defense")
					reagents.clear_reagents()
					amount_per_transfer_from_this = 10
						reagents.add_reagent_list(list("tirizene" = 14, "tiresolution" = 21, "bonehurtingjuice" = 14,))	// OOF

				if("Fun Chemicals")
					reagents.clear_reagents()
					amount_per_transfer_from_this = 5
						chosen_reagent = input(user, "What reagent do you want to dispense?") as null|anything in fun_ids
					if(chosen_reagent)
						reagents.add_reagent(chosen_reagent, 20, null)

		if("Debug")
			var/operation_selection = input(user, "Select an option", "Reagent fabricator", "cancel") in list("Select reagent", "Clear reagents", "Select transfer amount", "Cancel")
			switch (operation_selection)
				if("Select reagent")
					switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
						if("Enter ID")
							var/valid_id
							while(!valid_id)
								chosen_reagent = stripped_input(usr, "Enter the ID of the reagent you want to add.")
								if(!chosen_reagent) //Get me out of here!
									break
								for(var/ID in reagent_ids)
									if(ID == chosen_reagent)
										valid_id = 1
								if(!valid_id)
									to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")
						if("Choose ID")
							chosen_reagent = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in reagent_ids	
					if(chosen_reagent)
						reagents.add_reagent(chosen_reagent, 20, null)

				if("Clear reagents")
					reagents.clear_reagents()

				if("Select transfer amount")
					var/transfer_select = input(user, "Select the amount of reagents you'd like to inject.", "Transfer amount") as num|null
					if(transfer_select)
						amount_per_transfer_from_this = max(min(round(text2num(transfer_select)),20),1)

		else
			return