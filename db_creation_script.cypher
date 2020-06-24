// 0 - Schema constraints and indexes

CREATE CONSTRAINT ON (cs:ChemicalEntity) ASSERT cs.uri IS UNIQUE;
CREATE CONSTRAINT ON (pe:PharmacologicalEntity) ASSERT pe.uri IS UNIQUE;
CREATE CONSTRAINT ON (pe:ProteinEntity) ASSERT pe.uri IS UNIQUE;
CREATE CONSTRAINT ON (c:Carrier) ASSERT c.uri IS UNIQUE;
CREATE CONSTRAINT ON (e:Enzyme) ASSERT e.uri IS UNIQUE;
CREATE CONSTRAINT ON (t:PharmacologicalTarget) ASSERT t.uri IS UNIQUE;
CREATE CONSTRAINT ON (t:Transporter) ASSERT t.uri IS UNIQUE;

CREATE CONSTRAINT ON (mech:DdiMechanism) ASSERT mech.uri IS UNIQUE;
CREATE CONSTRAINT ON (mech:PkDdiMechanism) ASSERT mech.uri IS UNIQUE;
CREATE CONSTRAINT ON (mech:PdDdiMechanism) ASSERT mech.uri IS UNIQUE;

CREATE CONSTRAINT ON (ddi:DrugDrugInteraction) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:PdDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:TargetRelatedDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:AgonisticDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:AntagonisticDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:PkDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:CarrierRelatedDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:CarrierInductionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:CarrierInhibitionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:CarrierSaturationDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:EnzymeRelatedDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:EnzymaticSaturationDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:EnzymeInductionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:EnzymeInhibitionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:TransporterRelatedDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:TransporterInductionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:TransporterInhibitionDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:TransporterSaturationDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:PotentiallyBeneficialDdi) ASSERT ddi.uri IS UNIQUE;
CREATE CONSTRAINT ON (ddi:PotentiallyHarmfulDdi) ASSERT ddi.uri IS UNIQUE;

CREATE CONSTRAINT ON (pp:PharmacokineticParameter) ASSERT pp.uri IS UNIQUE;
CREATE CONSTRAINT ON (pp:PharmacokineticProcess) ASSERT pp.uri IS UNIQUE;

CREATE CONSTRAINT ON (eff:PhysiologicalEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:AdverseEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:AlteredPhysiologicalEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:TherapeuticEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:ToxicEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:BeneficialDdiEffect) ASSERT eff.uri IS UNIQUE;
CREATE CONSTRAINT ON (eff:HarmfulDdiEffect) ASSERT eff.uri IS UNIQUE;


CREATE CONSTRAINT ON (role:DrugRole) ASSERT role.uri IS UNIQUE;
CREATE CONSTRAINT ON (sub:StudySubject) ASSERT sub.uri IS UNIQUE;

CREATE CONSTRAINT ON (g:Gene) ASSERT g.name IS UNIQUE;
CREATE CONSTRAINT ON (ir:InformationResource) ASSERT ir.term IS UNIQUE;



CREATE INDEX ON :PharmacologicalEntity(preferredLabel);
CREATE INDEX ON :ProteinEntity(preferredLabel);
CREATE INDEX ON :ChemicalEntity(preferredLabel);
CREATE INDEX ON :Carrier(preferredLabel);
CREATE INDEX ON :Enzyme(preferredLabel);
CREATE INDEX ON :PharmacologicalTarget(preferredLabel);
CREATE INDEX ON :Transporter(preferredLabel);

CREATE INDEX ON :DdiMechanism(preferredLabel);

CREATE INDEX ON :DrugDrugInteraction(preferredLabel);
CREATE INDEX ON :PdDdi(preferredLabel);
CREATE INDEX ON :PkDdi(preferredLabel);

CREATE INDEX ON :PharmacokineticParameter(preferredLabel);

CREATE INDEX ON :PhysiologicalEffect(preferredLabel);
CREATE INDEX ON :AdverseEffect(preferredLabel);
CREATE INDEX ON :AlteredPhysiologicalEffect(preferredLabel);
CREATE INDEX ON :TherapeuticEffect(preferredLabel);
CREATE INDEX ON :ToxicEffect(preferredLabel);

CREATE INDEX ON :DrugRole(preferredLabel);


// 1 - Import DDIs, Adverse Effects and the rest of entities

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///DINTO_CSVLint.csv' AS line
WITH line, trim(line.`Preferred Label`) AS label
FOREACH(ignoreMe IN CASE WHEN label ENDS WITH "DDI" THEN [1] ELSE [] END | MERGE(ddi:DrugDrugInteraction {uri: line.`Class ID`, preferredLabel: label }));

LOAD CSV WITH HEADERS FROM 'file:///DINTO_CSVLint.csv' AS line
WITH line, trim(line.`Preferred Label`) AS label
FOREACH(ignoreMe IN CASE WHEN (label ENDS WITH "AE" OR label ENDS WITH "event" OR label ENDS WITH "adverse effect") THEN [1] ELSE [] END | MERGE(ae:AdverseEffect {uri: line.`Class ID`, preferredLabel: label }));

LOAD CSV WITH HEADERS FROM 'file:///DINTO_CSVLint.csv' AS line
WITH line, trim(line.`Preferred Label`) AS label
FOREACH(ignoreMe IN CASE WHEN (right(label,3) <> "DDI" AND right(label,2) <> "AE" AND right(label,5) <> "event" AND right(label,14) <> "adverse effect") THEN [1] ELSE [] END | MERGE(drug:PharmacologicalEntity {uri: line.`Class ID`, preferredLabel: label }));



// 2 - Import parental relationships and hierarchically set labels


LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.Parents, '|') AS parentEntities
UNWIND parentEntities AS i
MATCH (sourceEntity {uri: line.`Class ID`})
MATCH (destEntity {uri: i})
MERGE (sourceEntity)-[:PARENT_IS]->(destEntity);


// Define root node
MATCH (n)
WHERE n.uri = "http://www.w3.org/2002/07/owl#Thing"
SET n.preferredLabel = "owl:Thing", n:Thing
REMOVE n:PharmacologicalEntity;

// Set protein entities
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000129'})
REMOVE n1:PharmacologicalEntity
SET n1:ProteinEntity, n1:ChemicalEntity
RETURN n1.preferredLabel;

	// Set carriers
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000486'})
	REMOVE n1:PharmacologicalEntity
	SET n1:Carrier
	RETURN n1.preferredLabel;

	// Set enzymes
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000130'})
	REMOVE n1:PharmacologicalEntity
	SET n1:Enzyme
	RETURN n1.preferredLabel;

	// Set targets
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000128'})
	REMOVE n1:PharmacologicalEntity
	SET n1:PharmacologicalTarget
	RETURN n1.preferredLabel;

	// Set transporters
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000133'})
	REMOVE n1:PharmacologicalEntity
	SET n1:Transporter
	RETURN n1.preferredLabel;

	// Set receptor
	MATCH (n)
	WHERE n.preferredLabel = "receptor"
	REMOVE n:PharmacologicalEntity
	RETURN n;

// Set DDI mechanisms
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000003'})
REMOVE n1:PharmacologicalEntity
SET n1:DdiMechanism
RETURN n1.preferredLabel;

	// Set PK DDI mechanisms
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000004'})
	SET n1:PkDdiMechanism
	RETURN n1.preferredLabel;

	// Set PD DDI mechanisms
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000005'})
	SET n1:PdDdiMechanism
	RETURN n1.preferredLabel;

// Set DDIs
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000002'})
REMOVE n1:PharmacologicalEntity
SET n1:DrugDrugInteraction
SET n1.asserted = true
RETURN n1.preferredLabel;

	// Set PD DDIs
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000021'})
	SET n1:PdDdi
	RETURN n1.preferredLabel;

		// Set target related DDIs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_4332'})
		SET n1:TargetRelatedDdi
		RETURN n1.preferredLabel;

			// Set agonistic DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_4326'})
			SET n1:AgonisticDdi
			RETURN n1.preferredLabel;

			// Set antagonistic DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_4330'})
			SET n1:AntagonisticDdi
			RETURN n1.preferredLabel;

	// Set PK DDIs
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000020'})
	SET n1:PkDdi
	RETURN n1.preferredLabel;

		// Set carrier-related DDIs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_4329'})
		SET n1:CarrierRelatedDdi
		RETURN n1.preferredLabel;

			// Set carrier induction DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000173'})
			SET n1:CarrierInductionDdi
			RETURN n1.preferredLabel;

			// Set carrier inhibition DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000174'})
			SET n1:CarrierInhibitionDdi
			RETURN n1.preferredLabel;

			// Set carrier saturation DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000181'})
			SET n1:CarrierSaturationDdi
			RETURN n1.preferredLabel;

		// Set enzyme-related DDIs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_0001'})
		SET n1:EnzymeRelatedDdi
		RETURN n1.preferredLabel;

			// Set enzyme induction DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000169'})
			SET n1:EnzymeInductionDdi
			RETURN n1.preferredLabel;

			// Set enzyme inhibition DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000170'})
			SET n1:EnzymeInhibitionDdi
			RETURN n1.preferredLabel;

			// Set enzymatic saturation DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000176'})
			SET n1:EnzymaticSaturationDdi
			RETURN n1.preferredLabel;

		// Set transporter-related DDIs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_4331'})
		SET n1:TransporterRelatedDdi
		RETURN n1.preferredLabel;

			// Set transporter induction DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000171'})
			SET n1:TransporterInductionDdi
			RETURN n1.preferredLabel;

			// Set transporter inhibition DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000172'})
			SET n1:TransporterInhibitionDdi
			RETURN n1.preferredLabel;

			// Set transporter saturation DDIs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000179'})
			SET n1:TransporterSaturationDdi
			RETURN n1.preferredLabel;

// Set information resources
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://bioontology.org/ontologies/BiomedicalResourceOntology.owl#Information_Resource'})
REMOVE n1:PharmacologicalEntity
SET n1:InformationResource
RETURN n1.preferredLabel;

// Set pharmacokinetic parameters
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000053'})
REMOVE n1:PharmacologicalEntity
SET n1:PharmacokineticParameter
RETURN n1.preferredLabel;

// Set pharmacokinetic processes
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000030'})
REMOVE n1:PharmacologicalEntity
SET n1:PharmacokineticProcess
RETURN n1.preferredLabel;

// Set physiological effects
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000035'})
REMOVE n1:PharmacologicalEntity
SET n1:PhysiologicalEffect
RETURN n1.preferredLabel;

	// Set adverse effects
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/OAE_0000001'})
	SET n1:AdverseEffect
	RETURN n1.preferredLabel;

	// Set altered physiological effects
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000043'})
	SET n1:AlteredPhysiologicalEffect
	RETURN n1.preferredLabel;

	// Set therapeutic effects
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000036'})
	SET n1:TherapeuticEffect
	RETURN n1.preferredLabel;

	// Set toxic effects
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000037'})
	SET n1:ToxicEffect
	RETURN n1.preferredLabel;

// Set drug roles
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50906'})
REMOVE n1:PharmacologicalEntity, n1:ChemicalEntity
SET n1:DrugRole
RETURN n1.preferredLabel;

	// Set anti-anaemic agents
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_75835'})
	SET n1:AntiAnaemicAgent
	RETURN n1.preferredLabel;

	// Set anti-asthmatic agents
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_65023'})
	SET n1:AntiAsthmaticAgent
	RETURN n1.preferredLabel;
	
		// Set anti-asthmatic drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_49167'})
		SET n1:AntiAsthmaticDrug
		RETURN n1.preferredLabel;
	
	// Set anti-inflammatory agents
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_67079'})
	SET n1:AntiInflammatoryAgent
	RETURN n1.preferredLabel;
	
		// Set anti-inflammatory drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35472'})
		SET n1:AntiInflammatoryDrug
		RETURN n1.preferredLabel;

			// Set non-steroidal anti-inflammatory drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35475'})
			SET n1:Nsaid
			RETURN n1.preferredLabel;
	
	// Set drugs
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_23888'})
	SET n1:Drug
	RETURN n1.preferredLabel;

		// Set anaesthetics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38867'})
		SET n1:Anaesthetic
		RETURN n1.preferredLabel;

			// Set general anaesthetics
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38869'})
			SET n1:GeneralAnaesthetic
			RETURN n1.preferredLabel;

				// Set inhalation anaesthetics
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38870'})
				SET n1:InhalationAnaesthetic
				RETURN n1.preferredLabel;

				// Set intravenous anaesthetics
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38877'})
				SET n1:IntravenousAnaesthetic
				RETURN n1.preferredLabel;

			// Set local anaesthetics
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36333'})
			SET n1:LocalAnaesthetic
			RETURN n1.preferredLabel;

				// Set topical anaesthetics
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48425'})
				SET n1:TopicalAnaesthetic
				RETURN n1.preferredLabel;

		// Set analgesics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35480'})
		SET n1:Analgesic
		RETURN n1.preferredLabel;

			// Set non-narcotic analgesics
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35481'})
			SET n1:NonNarcoticAnalgesic
			RETURN n1.preferredLabel;

			// Set opioid analgesics
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35482'})
			SET n1:OpioidAnalgesic
			RETURN n1.preferredLabel;

		// Set angiogenesis inhibitor
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48422'})
		SET n1:AngiogenesisInhibitor
		RETURN n1.preferredLabel;

		// Set angiogenesis modulating agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50926'})
		SET n1:AngiogenesisModulatingAgent
		RETURN n1.preferredLabel;

			// Set angiogenesis inducing agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_65265'})
			SET n1:AngiogenesisInducingAgent
			RETURN n1.preferredLabel;

			// Set anti-angiogenic agent
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_67170'})
			SET n1:AntiAngiogenicAgent
			RETURN n1.preferredLabel;

			// Set pro-angiogenic agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_72571'})
			SET n1:ProAngiogenicAgent
			RETURN n1.preferredLabel;

		// Set antacids
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_65265'})
		SET n1:Antacid
		RETURN n1.preferredLabel;

		// Set anti-allergic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50857'})
		SET n1:AntiAllergicAgent
		RETURN n1.preferredLabel;

		// Set anti-asthmatic drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_49167'})
		SET n1:AntiAsthmaticDrug
		RETURN n1.preferredLabel;

		// Set anti-estrogens
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50751'})
		SET n1:AntiEstrogen
		RETURN n1.preferredLabel;

		// Set anti-inflammatory drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35472'})
		SET n1:AntiInflammatoryDrug
		RETURN n1.preferredLabel;

		// Set non-steroidal anti-inflammatory drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35475'})
		SET n1:Nsaid
		RETURN n1.preferredLabel;

		// Set anti-ulcer drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_49201'})
		SET n1:AntiUlcerDrug
		RETURN n1.preferredLabel;

		// Set antidyskinesia agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_66956'})
		SET n1:AntidyskinesiaAgent
		RETURN n1.preferredLabel;

			// Set antiparkinson drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48407'})
			SET n1:AntiparkinsonDrug
			RETURN n1.preferredLabel;

		// Set antiemetics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50919'})
		SET n1:Antiemetic
		RETURN n1.preferredLabel;

		// Set antihyperplasia drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_59844'})
		SET n1:AntihyperplasiaDrug
		RETURN n1.preferredLabel;

		// Set antiinfective agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35441'})
		SET n1:AntiinfectiveAgent
		RETURN n1.preferredLabel;

			// Set antimicrobial drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36043'})
			SET n1:AntimicrobialDrug
			RETURN n1.preferredLabel;

				// Set antibacterial drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36047'})
				SET n1:AntibacterialDrug
				RETURN n1.preferredLabel;

					// Set antimycobacterial drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_64912'})
					SET n1:AntimycobacterialDrug
					RETURN n1.preferredLabel;

						// Set antitubercular agents
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_33231'})
						SET n1:AntitubercularAgent
						RETURN n1.preferredLabel;

						// Set leprostatic drugs
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35816'})
						SET n1:LeprostaticDrug
						RETURN n1.preferredLabel;

					// Set antitreponemal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36050'})
					SET n1:AntitreponemalDrug
					RETURN n1.preferredLabel;

						// Set antisyphilitic drugs
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36051'})
						SET n1:AntisyphiliticDrug
						RETURN n1.preferredLabel;

				// Set antiprotozoal drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35820'})
				SET n1:AntiprotozoalDrug
				RETURN n1.preferredLabel;

					// Set antileishmanial agents
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_70868'})
					SET n1:AntileishmanialAgent
					RETURN n1.preferredLabel;

					// Set antimalarials
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38068'})
					SET n1:Antimalarial
					RETURN n1.preferredLabel;

					// Set antiplasmodial drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_64915'})
					SET n1:AntiplasmodialAgent
					RETURN n1.preferredLabel;

						// Set antimalarials
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38068'})
						SET n1:Antimalarial
						RETURN n1.preferredLabel;
					
					// Set antitrichomonal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50685'})
					SET n1:AntitrichomonalDrug
					RETURN n1.preferredLabel;

					// Set coccidiostats
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35818'})
					SET n1:Coccidiostat
					RETURN n1.preferredLabel;

					// Set trypannocidal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36335'})
					SET n1:TrypannocidalDrug
					RETURN n1.preferredLabel;

				// Set antiviral drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36044'})
				SET n1:AntiviralDrug
				RETURN n1.preferredLabel;

					// Set HIV fusion inhibitors
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_59886'})
					SET n1:HivFusionInhibitor
					RETURN n1.preferredLabel;
					
					// Set neuraminidase inhibitors
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_52425'})
					SET n1:NeuraminidaseInhibitor
					RETURN n1.preferredLabel;

			// Set antiparasitic agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35442'})
			SET n1:AntiparasiticAgent
			RETURN n1.preferredLabel;

				// Set acaricide drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36053'})
				SET n1:AcaricideDrug
				RETURN n1.preferredLabel;

				// Set anthelminthic drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35443'})
				SET n1:AnthelminthicDrug
				RETURN n1.preferredLabel;
				
					// Set antinematodal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35444'})
					SET n1:AntinematodalDrug
					RETURN n1.preferredLabel;
					
					// Set antiplatyhelmintic drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35684'})
					SET n1:AntiplatyhelminticDrug
					RETURN n1.preferredLabel;
				
						// Set schistosomicide drugs
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38941'})
						SET n1:SchistosomicideDrug
						RETURN n1.preferredLabel;
				
				// Set antiplasmodial drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_64915'})
				SET n1:AntiplasmodialDrug
				RETURN n1.preferredLabel;
								
					// Set antimalarial drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38068'})
					SET n1:AntimalarialDrug
					RETURN n1.preferredLabel;

				// Set antiprotozoal drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35820'})
				SET n1:AntiprotozoalDrug
				RETURN n1.preferredLabel;

					// Set antileishmanial agents
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_70868'})
					SET n1:AntileishmanialAgent
					RETURN n1.preferredLabel;

					// Set antimalarials
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38068'})
					SET n1:Antimalarial
					RETURN n1.preferredLabel;

					// Set antiplasmodial drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_64915'})
					SET n1:AntiplasmodialAgent
					RETURN n1.preferredLabel;

						// Set antimalarials
						MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38068'})
						SET n1:Antimalarial
						RETURN n1.preferredLabel;
					
					// Set antitrichomonal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50685'})
					SET n1:AntitrichomonalDrug
					RETURN n1.preferredLabel;

					// Set coccidiostats
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35818'})
					SET n1:Coccidiostat
					RETURN n1.preferredLabel;

					// Set trypannocidal drugs
					MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36335'})
					SET n1:TrypannocidalDrug
					RETURN n1.preferredLabel;

				// Set ectoparasitides
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38956'})
				SET n1:Ectoparasitide
				RETURN n1.preferredLabel;

			// Set antiseptic drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48218'})
			SET n1:AntisepticDrug
			RETURN n1.preferredLabel;

		// Set antilipemic drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35679'})
		SET n1:AntilipemicDrug
		RETURN n1.preferredLabel;

			// Set anticholesteremic drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35821'})
			SET n1:AnticholesteremicDrug
			RETURN n1.preferredLabel;

				// Set hydroxymethylglutaryl-CoA reductase inhibitor
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35664'})
				SET n1:HmgCoAReductaseInhibitor
				RETURN n1.preferredLabel;

		// Set antineoplastic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35610'})
		SET n1:AntineoplasticAgent
		RETURN n1.preferredLabel;

		// Set antipyretics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35493'})
		SET n1:Antipyretic
		RETURN n1.preferredLabel;

		// Set antirheumatic drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35842'})
		SET n1:AntirheumaticDrug
		RETURN n1.preferredLabel;

			// Set gout suppresants
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35845'})
			SET n1:GoutSuppresant
			RETURN n1.preferredLabel;

				// Set uricosuric drugs
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35841'})
				SET n1:UricosuricDrug
				RETURN n1.preferredLabel;

			// Set non-steroidal anti-inflamatory drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35475'})
			SET n1:Nsaid
			RETURN n1.preferredLabel;

		// Set antitussives
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_51177'})
		SET n1:Antitussive
		RETURN n1.preferredLabel;

		// Set appetite regulators
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50780'})
		SET n1:AppetiteRegulator
		RETURN n1.preferredLabel;

			// Set appetite depressants
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50507'})
			SET n1:AppetiteDepressant
			RETURN n1.preferredLabel;

			// Set appetite enhancers
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50779'})
			SET n1:AppetiteEnhancer
			RETURN n1.preferredLabel;

		// Set astringents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_74783'})
		SET n1:Astringent
		RETURN n1.preferredLabel;

		// Set bile therapy drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_61026'})
		SET n1:BileTherapyDrug
		RETURN n1.preferredLabel;

		// Set bone density conservation agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50646'})
		SET n1:BoneDensityConservationAgent
		RETURN n1.preferredLabel;

		// Set bronchoconstrictor agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50141'})
		SET n1:BronchoconstrictorAgent
		RETURN n1.preferredLabel;

		// Set bronchodilator agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35523'})
		SET n1:BronchodilatorAgent
		RETURN n1.preferredLabel;

		// Set calcimimetics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48525'})
		SET n1:Calcimimetic
		RETURN n1.preferredLabel;

		// Set cardiovascular drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35554'})
		SET n1:CardiovascularDrug
		RETURN n1.preferredLabel;

			// Set anti-arrhythmia drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38070'})
			SET n1:AntiArrhythmiaDrug
			RETURN n1.preferredLabel;

			// Set antiatherogenic agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50855'})
			SET n1:AntiatherogenicAgent
			RETURN n1.preferredLabel;

			// Set antihypertensive agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35674'})
			SET n1:AntihypertensiveAgent
			RETURN n1.preferredLabel;

				// Set angiotensin-converting enzyme inhibitor
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35457'})
				SET n1:AceInhibitor
				RETURN n1.preferredLabel;

			// Set cardiotonic drugs
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_38147'})
			SET n1:CardiotonicDrug
			RETURN n1.preferredLabel;

			// Set vasoconstrictor agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50514'})
			SET n1:VasoconstrictorAgent
			RETURN n1.preferredLabel;

			// Set vasodilator agents
			MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35620'})
			SET n1:VasodilatorAgent
			RETURN n1.preferredLabel;

				// Set partial prostacyclin agonist
				MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_51577'})
				SET n1:PartialProstacyclinAgonist
				RETURN n1.preferredLabel;

		// Set central nervous system drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35470'})
		SET n1:CentralNervousSystemDrug
		RETURN n1.preferredLabel;

		// Set depigmentation drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_59864'})
		SET n1:DepigmentationDrug
		RETURN n1.preferredLabel;

		// Set dermatologic drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50177'})
		SET n1:DermatologicDrug
		RETURN n1.preferredLabel;

		// Set diuretics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35498'})
		SET n1:Diuretic
		RETURN n1.preferredLabel;

		// Set estrogen receptor antagonists
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50792'})
		SET n1:EstrogenReceptorAntagonist
		RETURN n1.preferredLabel;

		// Set estrogen receptor modulators
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50739'})
		SET n1:EstrogenReceptorModulator
		RETURN n1.preferredLabel;

		// Set fibrin modulating drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_48676'})
		SET n1:FibrinModulatingDrug
		RETURN n1.preferredLabel;

		// Set gastrointestinal drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_55324'})
		SET n1:GastrointestinalDrug
		RETURN n1.preferredLabel;

		// Set hematologic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50248'})
		SET n1:HematologicAgent
		RETURN n1.preferredLabel;

		// Set hormone receptor modulators
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_51061'})
		SET n1:HormoneReceptorModulator
		RETURN n1.preferredLabel;

		// Set hypoglycemic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35526'})
		SET n1:HypoglycemicAgent
		RETURN n1.preferredLabel;

		// Set immunomodulators
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50846'})
		SET n1:Immunomodulator
		RETURN n1.preferredLabel;

		// Set interferon inducers
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36710'})
		SET n1:InterferonInducer
		RETURN n1.preferredLabel;

		// Set laxatives
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50503'})
		SET n1:Laxative
		RETURN n1.preferredLabel;

		// Set mydriatic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50513'})
		SET n1:MydriaticAgent
		RETURN n1.preferredLabel;

		// Set neuromuscular agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_51372'})
		SET n1:NeuromuscularAgent
		RETURN n1.preferredLabel;

		// Set neurotransmitter agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35942'})
		SET n1:NeurotransmitterAgent
		RETURN n1.preferredLabel;

		// Set nootropic agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_66980'})
		SET n1:NootropicAgent
		RETURN n1.preferredLabel;

		// Set nutraceuticals
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50733'})
		SET n1:Nutraceutical
		RETURN n1.preferredLabel;

		// Set ophthalmology drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_66981'})
		SET n1:OphthalmologyDrug
		RETURN n1.preferredLabel;

		// Set orphan drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_71031'})
		SET n1:OrphanDrug
		RETURN n1.preferredLabel;

		// Set oxytocics
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_36063'})
		SET n1:Oxytocic
		RETURN n1.preferredLabel;

		// Set peripheral nervous system drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_49110'})
		SET n1:PeripheralNervousSystemDrug
		RETURN n1.preferredLabel;

		// Set photosensitizing agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_47868'})
		SET n1:PhotosensitizingAgent
		RETURN n1.preferredLabel;

		// Set prodrugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50266'})
		SET n1:Prodrug
		RETURN n1.preferredLabel;

		// Set proteasome inhibitors
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_52726'})
		SET n1:ProteasomeInhibitor
		RETURN n1.preferredLabel;

		// Set protective agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50267'})
		SET n1:ProtectiveAgent
		RETURN n1.preferredLabel;

		// Set renal agents
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_35846'})
		SET n1:RenalAgent
		RETURN n1.preferredLabel;

		// Set reproductive control drugs
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_50689'})
		SET n1:ReproductiveControlDrug
		RETURN n1.preferredLabel;

		// Set vulneraries
		MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_73336'})
		SET n1:Vulnerary
		RETURN n1.preferredLabel;

	// Set diagnostic agents
	MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/CHEBI_33295'})
	SET n1:DiagnosticAgent
	RETURN n1.preferredLabel;


// Set study subjects
MATCH(n) WHERE n.preferredLabel IN ["study subject", "animal", "human", "healthy volunteer", "patient"]
REMOVE n:PharmacologicalEntity
SET n:StudySubject
RETURN n.preferredLabel;


// Further adjustments
// Remove all incorrect binds to drugs:
MATCH (n)
REMOVE n:PharmacologicalEntity;

// Set drugs
MATCH (n1)-[:PARENT_IS *0..]->(n2 {uri: 'http://purl.obolibrary.org/obo/dinto_000055'})
SET n1:PharmacologicalEntity, n1:ChemicalEntity
RETURN n1.preferredLabel;

// Set chemical entities
MATCH (n:ProteinEntity)
SET n:ChemicalEntity;


// 3 - Import the remaining object properties




LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.activates, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:ACTIVATES]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.adsorbs, '|') AS dests
UNWIND dests AS i
MATCH (source:ChemicalEntity {uri: line.`Class ID`})
MATCH (dest:ChemicalEntity {uri: i})
MERGE (source)-[r:ADSORBS]->(dest)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.alters, '|') AS dests
UNWIND dests AS i
MATCH (source {uri: line.`Class ID`})
MATCH (dest:PharmacokineticProcess {uri: i})
MERGE (source)-[r:ALTERS]->(dest)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.binds, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:BINDS]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.blocks, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:BLOCKS]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.carries, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:CARRIES]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.chelates, '|') AS elements
UNWIND elements AS i
MATCH (chemElement1:ChemicalEntity {uri: line.`Class ID`})
MATCH (chemElement2:ChemicalEntity {uri: i})
MERGE (chemElement1)-[r:CHELATES]->(chemElement2)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.decreases, '|') AS elements
//UNWIND elements AS i
//MATCH (element1:Thing {uri: line.`Class ID`})
//MATCH (element2:Thing {uri: i})
//MERGE (element1)-[r:DECREASES]->(element2)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.describes, '|') AS elements
UNWIND elements AS i
MATCH (resource:InformationResource {uri: line.`Class ID`})
MATCH (ddi:DrugDrugInteraction {uri: i})
MERGE (resource)-[r:DESCRIBES]->(ddi)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.determines, '|') AS elements
//UNWIND elements AS i
//MATCH (a:Thing {uri: line.`Class ID`})
//MATCH (b:Thing {uri: i})
//MERGE (a)-[r:DETERMINES]->(b)
//SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.facilitates, '|') AS processes
//UNWIND processes AS i
//MATCH (element:Thing {uri: line.`Class ID`})
//MATCH (process {uri: i})
//MERGE (process)-[r:FACILITATES]->(element)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has agent`, '|') AS agents
UNWIND agents AS i
MATCH (mech:DdiMechanism {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (mech)-[r:HAS_AGENT]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has DDI effect`, '|') AS effects
UNWIND effects AS i
MATCH (ddi:DrugDrugInteraction {uri: line.`Class ID`})
MATCH (effect:AlteredPhysiologicalEffect {uri: i})
MERGE (ddi)-[r:HAS_DDI_EFFECT]->(effect)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has effect`, '|') AS effects
UNWIND effects AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (effect:PhysiologicalEffect {uri: i})
MERGE (drug)-[r:HAS_EFFECT]->(effect)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has metabolite`, '|') AS metabolites
UNWIND metabolites AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (metabolite:PharmacologicalEntity {uri: i})
MERGE (drug)-[r:HAS_METABOLITE]->(metabolite)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has object`, '|') AS objects
UNWIND objects AS i
MATCH (ddi:DrugDrugInteraction {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (ddi)-[r:HAS_OBJECT]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has parameter`, '|') AS parameters
UNWIND parameters AS i
MATCH (process:PharmacokineticProcess {uri: line.`Class ID`})
MATCH (parameter:PharmacokineticParameter {uri: i})
MERGE (process)-[r:HAS_PARAMETER]->(parameter)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has participant`, '|') AS drugs
UNWIND drugs AS i
MATCH (ddi:DrugDrugInteraction {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (ddi)-[r:HAS_PARTICIPANT]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has pharmacological target`, '|') AS targets
UNWIND targets AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ChemicalEntity {uri: i})
MERGE (drug)-[r:HAS_PHARMACOLOGICAL_TARGET]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has precipitant`, '|') AS drugs
UNWIND drugs AS i
MATCH (ddi:DrugDrugInteraction {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (ddi)-[r:HAS_PRECIPITANT]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has product`, '|') AS drugs
UNWIND drugs AS i
MATCH (process:PharmacokineticProcess {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (process)-[r:HAS_PRODUCT]->(drug)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`has quality`, '|') AS qualities
//UNWIND qualities AS i
//MATCH (thing1:Thing {uri: line.`Class ID`})
//MATCH (thing2:Thing {uri: i})
//MERGE (thing1)-[r:HAS_QUALITY]->(thing2)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has role`, '|') AS roles
UNWIND roles AS i
MATCH (chemical:ChemicalEntity {uri: line.`Class ID`})
MATCH (role:DrugRole {uri: i})
MERGE (chemical)-[r:HAS_ROLE]->(role)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has study entity`, '|') AS drugs
UNWIND drugs AS i
MATCH (resource:InformationResource {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (resource)-[r:HAS_STUDY_ENTITY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has study subject`, '|') AS subjects
UNWIND subjects AS i
MATCH (resource:InformationResource {uri: line.`Class ID`})
MATCH (subject:StudySubject {uri: i})
MERGE (resource)-[r:HAS_STUDY_SUBJECT]->(subject)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`has substrate`, '|') AS chemicals
UNWIND chemicals AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (chemical:ChemicalEntity {uri: i})
MERGE (biomol)-[r:HAS_SUBSTRATE]->(chemical)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.impairs, '|') AS processes
//UNWIND processes AS i
//MATCH (element:Thing {uri: line.`Class ID`})
//MATCH (process {uri: i})
//MERGE (process)-[r:IMPAIRS]->(element)
//SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.increases, '|') AS elements
//UNWIND elements AS i
//MATCH (element1:Thing {uri: line.`Class ID`})
//MATCH (element2:Thing {uri: i})
//MERGE (element1)-[r:INCREASES]->(element2)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.induces, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:INDUCES]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.inhibits, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:INHIBITS]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is activated by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_ACTIVATED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is agent in`, '|') AS mechanisms
UNWIND mechanisms AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (mech:DdiMechanism {uri: i})
MERGE (drug)-[r:IS_AGENT_IN]->(mech)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is altered by`, '|') AS dests
UNWIND dests AS i
MATCH (source:PharmacokineticProcess {uri: line.`Class ID`})
MATCH (dest {uri: i})
MERGE (source)-[r:IS_ALTERED_BY]->(dest)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is binded by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_BINDED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is blocked by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_BLOCKED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is carried by`, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:IS_CARRIED_BY]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is chelated by`, '|') AS drugs
UNWIND drugs AS i
MATCH (chemElement1:ChemicalEntity {uri: line.`Class ID`})
MATCH (chemElement2:ChemicalEntity {uri: i})
MERGE (chemElement1)-[r:IS_CHELATED_BY]->(chemElement2)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is DDI effect of`, '|') AS ddis
UNWIND ddis AS i
MATCH (effect:AlteredPhysiologicalEffect {uri: line.`Class ID`})
MATCH (ddi:DrugDrugInteraction {uri: i})
MERGE (effect)-[r:IS_DDI_EFFECT_OF]->(ddi)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is decreased by`, '|') AS elements
//UNWIND elements AS i
//MATCH (element1:Thing {uri: line.`Class ID`})
//MATCH (element2:Thing {uri: i})
//MERGE (element1)-[r:IS_DECREASED_BY]->(element2)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is described in`, '|') AS resources
UNWIND resources AS i
MATCH (ddi:DrugDrugInteraction {uri: line.`Class ID`})
MATCH (resource:InformationResource {uri: i})
MERGE (ddi)-[r:IS_DESCRIBED_IN]->(resource)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is determined by`, '|') AS elements
UNWIND elements AS i
MATCH (a:Thing {uri: line.`Class ID`})
MATCH (b:Thing {uri: i})
MERGE (a)-[r:IS_DETERMINED_BY]->(b)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is effect of`, '|') AS drugs
UNWIND drugs AS i
MATCH (effect:PhysiologicalEffect {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (effect)-[r:IS_EFFECT_OF]->(drug)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is facilitated by`, '|') AS elements
//UNWIND elements AS i
//MATCH (process:Thing {uri: line.`Class ID`})
//MATCH (element:Thing {uri: i})
//MERGE (process)-[r:IS_FACILITATED_BY]->(element)
//SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is impaired by`, '|') AS elements
//UNWIND elements AS i
//MATCH (process:Thing {uri: line.`Class ID`})
//MATCH (element:Thing {uri: i})
//MERGE (process)-[r:IS_IMPAIRED_BY]->(element)
//SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is increased by`, '|') AS elements
//UNWIND elements AS i
//MATCH (element1:Thing {uri: line.`Class ID`})
//MATCH (element2:Thing {uri: i})
//MERGE (element1)-[r:IS_INCREASED_BY]->(element2)
//SET r.asserted = true RETURN r;


LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is induced by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_INDUCED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is inhibited by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_INHIBITED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is metabolised by`, '|') AS enzymes
UNWIND enzymes AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (enzyme:Enzyme {uri: i})
MERGE (drug)-[r:IS_METABOLISED_BY]->(enzyme)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is metabolite of`, '|') AS drugs
UNWIND drugs AS i
MATCH (metabolite:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (metabolite)-[r:IS_METABOLITE_OF]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is modulated by`, '|') AS drugs
UNWIND drugs AS i
MATCH (biomol:ProteinEntity {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (biomol)-[r:IS_MODULATED_BY]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is object in`, '|') AS ddis
UNWIND ddis AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (ddi:DrugDrugInteraction {uri: i})
MERGE (drug)-[r:IS_OBJECT_IN]->(ddi)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is parameter of`, '|') AS processes
UNWIND processes AS i
MATCH (parameter:PharmacokineticParameter {uri: line.`Class ID`})
MATCH (process:PharmacokineticProcess {uri: i})
MERGE (parameter)-[r:IS_PARAMETER_OF]->(process)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is participant in`, '|') AS ddis
UNWIND ddis AS i
MATCH (entity:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (ddi:DrugDrugInteraction {uri: i})
MERGE (entity)-[r:IS_PARTICIPANT_IN]->(ddi)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is pharmacological target of`, '|') AS drugs
UNWIND drugs AS i
MATCH (target:PharmacologicalTarget {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (target)-[r:IS_PHARMACOLOGICAL_TARGET_OF]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is preceded by`, '|') AS processes
UNWIND processes AS i
MATCH (process1 {uri: line.`Class ID`})
MATCH (process2 {uri: i})
MERGE (process1)-[r:IS_PRECEDED_BY]->(process2)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is precipitant in`, '|') AS ddis
UNWIND ddis AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (ddi:DrugDrugInteraction {uri: i})
MERGE (drug)-[r:IS_PRECIPITANT_IN]->(ddi)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is product of`, '|') AS processes
UNWIND processes AS i
MATCH (metabolite:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (process:PharmacokineticProcess {uri: i})
MERGE (metabolite)-[r:IS_PRODUCT_OF]->(process)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is quality of`, '|') AS qualities
//UNWIND qualities AS i
//MATCH (thing1:Thing {uri: line.`Class ID`})
//MATCH (thing2:Thing {uri: i})
//MERGE (thing1)-[r:IS_QUALITY_OF]->(thing2)
//SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.`is regulated by`, '|') AS elements
//UNWIND elements AS i
//MATCH (process:PharmacokineticProcess {uri: line.`Class ID`})
//MATCH (thing:Thing {uri: i})
//MERGE (process)-[r:IS_REGULATED_BY]->(thing)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is role of`, '|') AS chemicals
UNWIND chemicals AS i
MATCH (role:DrugRole {uri: line.`Class ID`})
MATCH (chemical:ChemicalEntity {uri: i})
MERGE (role)-[r:IS_ROLE_OF]->(chemical)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is substrate of`, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (chemical:ChemicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (chemical)-[r:IS_SUBSTRATE_OF]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is transported by`, '|') AS transporters
UNWIND transporters AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (transporter:Transporter {uri: i})
MERGE (drug)-[r:IS_TRANSPORTED_BY]->(transporter)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`is undergone by`, '|') AS chemicals
UNWIND chemicals AS i
MATCH (process:PharmacokineticProcess {uri: line.`Class ID`})
MATCH (chemical:PharmacologicalEntity {uri: i})
MERGE (process)-[r:IS_UNDERGONE_BY]->(chemical)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`may interact with`, '|') AS ddiDrugs
UNWIND ddiDrugs AS i
MATCH (sourceDrug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (destDrug:PharmacologicalEntity {uri: i})
MERGE (sourceDrug)-[r:MAY_INTERACT_WITH]->(destDrug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.metabolizes, '|') AS drugs
UNWIND drugs AS i
MATCH (enzyme:Enzyme {uri: line.`Class ID`})
MATCH (destDrug:PharmacologicalEntity {uri: i})
MERGE (enzyme)-[r:METABOLIZES]->(destDrug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.modulates, '|') AS biomolecules
UNWIND biomolecules AS i
MATCH (drug:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (biomol:ProteinEntity {uri: i})
MERGE (drug)-[r:MODULATES]->(biomol)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.precedes, '|') AS processes
UNWIND processes AS i
MATCH (process1 {uri: line.`Class ID`})
MATCH (process2 {uri: i})
MERGE (process1)-[r:PRECEDES]->(process2)
SET r.asserted = true RETURN r;

//LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
//WITH line, SPLIT(line.regulates, '|') AS processes
//UNWIND processes AS i
//MATCH (thing:Thing {uri: line.`Class ID`})
//MATCH (process:PharmacokineticProcess {uri: i})
//MERGE (thing)-[r:REGULATES]->(processes)
//SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.`related with`, '|') AS proteins
UNWIND proteins AS i
MATCH (source:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (dest:ProteinEntity {uri: i})
MERGE (source)-[r:RELATED_WITH]->(dest)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.transports, '|') AS drugs
UNWIND drugs AS i
MATCH (transporter:Transporter {uri: line.`Class ID`})
MATCH (drug:PharmacologicalEntity {uri: i})
MERGE (transporter)-[r:TRANSPORTS]->(drug)
SET r.asserted = true RETURN r;

LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(line.undergoes, '|') AS processes
UNWIND processes AS i
MATCH (chemical:PharmacologicalEntity {uri: line.`Class ID`})
MATCH (process:PharmacokineticProcess {uri: i})
MERGE (chemical)-[r:UNDERGOES]->(process)
SET r.asserted = true RETURN r;



LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, TRIM(line.Gene) AS gene
MATCH (protein:ProteinEntity {uri: line.`Class ID`})
FOREACH (ignoreMe IN CASE WHEN gene <> "" THEN [1] ELSE [] END | 
	MERGE (n:Gene {name: gene}) 
	MERGE (protein)-[r1:CODIFIED_BY]->(n)
	MERGE (n)-[r2:CODIFIES]->(protein)
);


// One final assurance setting: PK DDIs and PD DDIs
	// Set PK DDIs
	MATCH (n1)-[:IS_PRECEDED_BY *1..]->(n2:PkDdiMechanism)
	SET n1:PkDdi
	RETURN n1.preferredLabel;

	// Set PD DDIs
	MATCH (n1)-[:IS_PRECEDED_BY *1..]->(n2:PdDdiMechanism)
	SET n1:PdDdi
	RETURN n1.preferredLabel;

// 4 - Import attributes

USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///DINTO_CSVLint.csv" AS line
WITH line, SPLIT(TRIM(line.Synonyms), '|') AS synonyms
WITH line, synonyms, SPLIT(TRIM(line.AHFScode), '|') AS ahfsCodes
WITH line, synonyms, ahfsCodes, SPLIT(TRIM(line.`alternative term`), '|') AS altTerms
WITH line, synonyms, ahfsCodes, altTerms, SPLIT(TRIM(line.altId), '|') AS altIds
WITH line, synonyms, ahfsCodes, altTerms, altIds, SPLIT(TRIM(line.ATCCode), '|') AS atcCodes
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, SPLIT(TRIM(line.DBBrand), '|') AS dbBrands
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, SPLIT(TRIM(line.DBSalt), '|') AS dbSalts
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, SPLIT(TRIM(line.DBSynonym), '|') AS dbSynonyms
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, SPLIT(TRIM(line.`definition source`), '|') AS definitionSources
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, definitionSources, SPLIT(TRIM(line.`http://purl.org/dc/elements/1.1/creator`), ',') AS creators
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, definitionSources, creators, SPLIT(TRIM(line.`http://www.w3.org/2000/01/rdfschema#comment`), '|') AS rdfSchemaComments
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, definitionSources, creators, rdfSchemaComments, SPLIT(TRIM(line.`http://www.w3.org/2000/01/rdfschema#seeAlso`), '|') AS seeAlso
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, definitionSources, creators, rdfSchemaComments, seeAlso, SPLIT(TRIM(line.`term editor`), ',') AS termEditors
WITH line, synonyms, ahfsCodes, altTerms, altIds, atcCodes, dbBrands, dbSalts, dbSynonyms, definitionSources, creators, rdfSchemaComments, seeAlso, termEditors, SPLIT(TRIM(line.xref), '|') AS xrefs

MATCH (entity {uri: line.`Class ID`})
FOREACH (ignoreMe IN CASE WHEN synonyms <> [""] THEN [1] ELSE [] END | SET entity.synonyms = synonyms)
FOREACH (ignoreMe IN CASE WHEN ahfsCodes <> [""] THEN [1] ELSE [] END | SET entity.ahfsCodes = ahfsCodes)
FOREACH (ignoreMe IN CASE WHEN altTerms <> [""] THEN [1] ELSE [] END | SET entity.alternativeTerms = altTerms)
FOREACH (ignoreMe IN CASE WHEN altIds <> [""] THEN [1] ELSE [] END | SET entity.altIds = altIds)
FOREACH (ignoreMe IN CASE WHEN atcCodes <> [""] THEN [1] ELSE [] END | SET entity.atcCodes = atcCodes)
FOREACH (ignoreMe IN CASE WHEN dbBrands <> [""] THEN [1] ELSE [] END | SET entity.dbBrands = dbBrands)
FOREACH (ignoreMe IN CASE WHEN dbSalts <> [""] THEN [1] ELSE [] END | SET entity.dbSalts = dbSalts)
FOREACH (ignoreMe IN CASE WHEN dbSynonyms <> [""] THEN [1] ELSE [] END | SET entity.dbSynonyms = dbSynonyms)
FOREACH (ignoreMe IN CASE WHEN definitionSources <> [""] THEN [1] ELSE [] END | SET entity.definitionSources = definitionSources)
FOREACH (ignoreMe IN CASE WHEN creators <> [""] THEN [1] ELSE [] END | SET entity.creators = creators)
FOREACH (ignoreMe IN CASE WHEN rdfSchemaComments <> [""] THEN [1] ELSE [] END | SET entity.rdfSchemaComments = rdfSchemaComments)
FOREACH (ignoreMe IN CASE WHEN seeAlso <> [""] THEN [1] ELSE [] END | SET entity.seeAlso = seeAlso)
FOREACH (ignoreMe IN CASE WHEN termEditors <> [""] THEN [1] ELSE [] END | SET entity.termEditors = termEditors)
FOREACH (ignoreMe IN CASE WHEN xrefs <> [""] THEN [1] ELSE [] END | SET entity.xrefs = xrefs)

FOREACH(ignoreMe IN CASE WHEN TRIM(line.Definitions) <> "" THEN [1] ELSE [] END | SET entity.definitions = TRIM(line.Definitions))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.Obsolete) <> "" THEN [1] ELSE [] END | SET entity.obsolete = TRIM(line.Obsolete))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.CUI) <> "" THEN [1] ELSE [] END | SET entity.cui = TRIM(line.CUI))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`Semantic Types`) <> "" THEN [1] ELSE [] END | SET entity.semanticTypes = TRIM(line.`Semantic Types`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`alternative label`) <> "" THEN [1] ELSE [] END | SET entity.alternativeLabel = TRIM(line.`alternative label`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`antisymmetric property`) <> "" THEN [1] ELSE [] END | SET entity.antisymmetricProperty = TRIM(line.`antisymmetric property`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`BFO CLIF specification label`) <> "" THEN [1] ELSE [] END | SET entity.bfoClif = TRIM(line.`BFO CLIF specification label`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`BFO OWL specification label`) <> "" THEN [1] ELSE [] END | SET entity.bfoOwl = TRIM(line.`BFO OWL specification label`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.CASRN) <> "" THEN [1] ELSE [] END | SET entity.casrn = TRIM(line.CASRN))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`change note`) <> "" THEN [1] ELSE [] END | SET entity.changeNote = TRIM(line.`change note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`curator note`) <> "" THEN [1] ELSE [] END | SET entity.curatorNote = TRIM(line.`curator note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.database_cross_reference) <> "" THEN [1] ELSE [] END | SET entity.dbCrossReference = TRIM(line.database_cross_reference))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.DBname) <> "" THEN [1] ELSE [] END | SET entity.dbName = TRIM(line.DBname))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.Definition) <> "" THEN [1] ELSE [] END | SET entity.definition = TRIM(line.Definition))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`editor note`) <> "" THEN [1] ELSE [] END | SET entity.editorNote = TRIM(line.`editor note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`editor preferred term`) <> "" THEN [1] ELSE [] END | SET entity.editorPreferredTerm = TRIM(line.`editor preferred term`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`editorial note`) <> "" THEN [1] ELSE [] END | SET entity.editorialNote = TRIM(line.`editorial note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.elucidation) <> "" THEN [1] ELSE [] END | SET entity.elucidation = TRIM(line.elucidation))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.example) <> "" THEN [1] ELSE [] END | SET entity.example = TRIM(line.example))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`example of usage`) <> "" THEN [1] ELSE [] END | SET entity.exampleOfUsage = TRIM(line.`example of usage`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`first order logic expression`) <> "" THEN [1] ELSE [] END | SET entity.firstOrderLogicExpr = TRIM(line.`first order logic expression`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has administration route`) <> "" THEN [1] ELSE [] END | SET entity.administrationRoute = TRIM(line.`has administration route`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has age`) <> "" THEN [1] ELSE [] END | SET entity.age = TRIM(line.`has age`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has concentration`) <> "" THEN [1] ELSE [] END | SET entity.concentration = TRIM(line.`has concentration`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has documentation level`) <> "" THEN [1] ELSE [] END | SET entity.documentationLevel = TRIM(line.`documentation level`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has dose`) <> "" THEN [1] ELSE [] END | SET entity.dose = TRIM(line.`has dose`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has dose recommendation`) <> "" THEN [1] ELSE [] END | SET entity.doseRecommendation = TRIM(line.`has dose recommendation`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has drug selection recommendation`) <> "" THEN [1] ELSE [] END | SET entity.drugSelectionRecommendation = TRIM(line.`has drug selection recommendation`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has gender`) <> "" THEN [1] ELSE [] END | SET entity.gender = TRIM(line.`has gender`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has incidence`) <> "" THEN [1] ELSE [] END | SET entity.incidence = TRIM(line.`has incidence`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has monitoring recommendation`) <> "" THEN [1] ELSE [] END | SET entity.monitoringRecommendation = TRIM(line.`has monitoring recommendation`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has onset`) <> "" THEN [1] ELSE [] END | SET entity.onset = TRIM(line.`has onset`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has pharmaceutical form`) <> "" THEN [1] ELSE [] END | SET entity.pharmaceuticalForm = TRIM(line.`has pharmaceutical form`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has race or ethnic`) <> "" THEN [1] ELSE [] END | SET entity.raceOrEthnic = TRIM(line.`has race or ethnic`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has relevance`) <> "" THEN [1] ELSE [] END | SET entity.relevance = TRIM(line.`has relevance`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has severity`) <> "" THEN [1] ELSE [] END | SET entity.severity = TRIM(line.`has severity`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has subject number`) <> "" THEN [1] ELSE [] END | SET entity.subjectNumber = TRIM(line.`has subject number`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`has test recommendation`) <> "" THEN [1] ELSE [] END | SET entity.testRecommendation = TRIM(line.`has test recommendation`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`hidden label`) <> "" THEN [1] ELSE [] END | SET entity.hiddenLabel = TRIM(line.`hidden label`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`history note`) <> "" THEN [1] ELSE [] END | SET entity.historyNote = TRIM(line.`history note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`http://data.bioontology.org/metadata/prefixIRI`) <> "" THEN [1] ELSE [] END | SET entity.bioOntologyPrefixIRI = TRIM(line.`http://data.bioontology.org/metadata/prefixIRI`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`imported from`) <> "" THEN [1] ELSE [] END | SET entity.importedFrom = TRIM(line.`imported from`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.InChI) <> "" THEN [1] ELSE [] END | SET entity.inChI = TRIM(line.InChI))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.InChIKey) <> "" THEN [1] ELSE [] END | SET entity.inChIKey = TRIM(line.InChIKey))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.label) <> "" THEN [1] ELSE [] END | SET entity.label = TRIM(line.label))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`maps to`) <> "" THEN [1] ELSE [] END | SET entity.mapsTo = TRIM(line.`maps to`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.note) <> "" THEN [1] ELSE [] END | SET entity.note = TRIM(line.note))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.OrganismClass) <> "" THEN [1] ELSE [] END | SET entity.organismClass = TRIM(line.OrganismClass))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.`scope note`) <> "" THEN [1] ELSE [] END | SET entity.scopeNote = TRIM(line.`scope note`))
FOREACH(ignoreMe IN CASE WHEN TRIM(line.SMILES) <> "" THEN [1] ELSE [] END | SET entity.smiles = TRIM(line.SMILES))
RETURN entity;