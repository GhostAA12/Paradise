#define INFECTION_COUNT 5

datum/directive/bluespace_contagion
	var/list/infected = list()

	proc/get_infection_candidates()
		var/list/candidates[0]
		for(var/mob/M in player_list)
			if (!M.is_mechanical() && M.is_ready())
				candidates+=(M)
		return candidates

datum/directive/bluespace_contagion/get_description()
	return {"
		<p>
			A manufactured and near-undetectable virus is spreading on NanoTrasen stations.
			The pathogen travels by bluespace after maturing for one day.
			No treatment has yet been discovered. Personnel onboard [station_name()] have been infected. Further information is classified.
		</p>
	"}

datum/directive/bluespace_contagion/initialize()
	var/list/candidates = get_infection_candidates()
	var/list/infected_names = list()
	for(var/i=0, i < INFECTION_COUNT, i++)
		if(!candidates.len)
			break

		var/mob/candidate = pick(candidates)
		candidates-=candidate
		infected+=candidate
		infected_names+="[candidate.mind.assigned_role] [candidate.mind.name]"

	special_orders = list(
		"Quarantine these personnel: [list2text(infected_names, ", ")].",
		"Allow one hour for a cure to be manufactured.",
		"If no cure arrives after that time, execute the infected.")

datum/directive/bluespace_contagion/meets_prerequisites()
	var/list/candidates = get_infection_candidates()
	return candidates.len >= 7

datum/directive/bluespace_contagion/directives_complete()
	return infected.len == 0

datum/directive/bluespace_contagion/get_remaining_orders()
	var/text = ""
	for(var/victim in infected)
		text += "<li>Kill [victim]</li>"
	return text

/hook/death/proc/infected_killed(mob/living/carbon/human/deceased, gibbed)
	var/datum/directive/bluespace_contagion/D = get_directive("bluespace_contagion")
	if(!D) return 1

	if(deceased in D.infected)
		D.infected-=deceased
	return 1
