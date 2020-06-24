RETURN TIMESTAMP();


MATCH (a:PharmacologicalEntity)-[:ACTIVATES]->(b:ProteinEntity)
   MERGE (b)-[r:IS_ACTIVATED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_ACTIVATED_BY]->(a:PharmacologicalEntity)
   MERGE (a)-[r:ACTIVATES]->(b) SET r.inferred = true;

MATCH (a:ChemicalEntity)-[:ADSORBS]->(b:ChemicalEntity)
WHERE a <> b
   MERGE (b)-[r:IS_ADSORBED_BY]->(a) SET r.inferred = true;

MATCH (b:ChemicalEntity)-[:IS_ADSORBED_BY]->(a:ChemicalEntity)
WHERE a <> b
   MERGE (a)-[r:ADSORBS]->(b) SET r.inferred = true;

MATCH (a)-[:ALTERS]->(b)
WHERE a <> b
   MERGE (b)-[r:IS_ALTERED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_ALTERED_BY]->(b)
WHERE a <> b
   MERGE (b)-[r:ALTERS]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:BINDS]->(b:ProteinEntity)
   MERGE (b)-[r:IS_BINDED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_BINDED_BY]->(a:PharmacologicalEntity)
   MERGE (a)-[r:BINDS]->(b) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:BLOCKS]->(b:ProteinEntity)
   MERGE (b)-[r:IS_BLOCKED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_BLOCKED_BY]->(a:PharmacologicalEntity)
   MERGE (a)-[r:BLOCKS]->(b) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:CARRIES]->(a:PharmacologicalEntity)
   MERGE (a)-[r:IS_CARRIED_BY]->(b) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_CARRIED_BY]->(b:ProteinEntity)
   MERGE (b)-[r:CARRIES]->(a) SET r.inferred = true;

MATCH (a:ChemicalEntity)-[:CHELATES]->(b:ChemicalEntity)
WHERE a <> b
   MERGE (b)-[r:IS_CHELATED_BY]->(a) SET r.inferred = true;

MATCH (b:ChemicalEntity)-[:IS_CHELATED_BY]->(a:ChemicalEntity)
WHERE a <> b
   MERGE (a)-[r:CHELATES]->(b) SET r.inferred = true;

MATCH (ddi:DrugDrugInteraction)-[:IS_DESCRIBED_IN]->(ir:InformationResource)
   MERGE (ir)-[r:DESCRIBES]->(ddi) SET r.inferred = true;

MATCH (ir:InformationResource)-[:DESCRIBES]->(ddi:DrugDrugInteraction)
   MERGE (ddi)-[r:IS_DESCRIBED_IN]->(ir) SET r.inferred = true;

MATCH (a)-[:DETERMINES]->(b)
WHERE a <> b
MERGE (b)-[r:IS_DETERMINED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_DETERMINED_BY]->(b)
WHERE a <> b
MERGE (b)-[r:DETERMINES]->(a) SET r.inferred = true;

MATCH (a)-[:FACILITATES]->(b)
WHERE a <> b
MERGE (b)-[r:IS_FACILITATED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_FACILITATED_BY]->(b)
WHERE a <> b
MERGE (b)-[r:FACILITATES]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_AGENT_IN]->(mechanism:DdiMechanism)
MERGE (mechanism)-[r:HAS_AGENT]->(a) SET r.inferred = true;

MATCH (mechanism:DdiMechanism)-[:HAS_AGENT]->(a:PharmacologicalEntity)
MERGE (a)-[r:IS_AGENT_IN]->(mechanism) SET r.inferred = true;

MATCH (ddi:DrugDrugInteraction)-[:HAS_DDI_EFFECT]->(effect:PhysiologicalEffect)
MERGE (effect)-[r:IS_DDI_EFFECT_OF]->(ddi) SET r.inferred = true;

MATCH (effect:PhysiologicalEffect)-[:IS_DDI_EFFECT_OF]->(ddi:DrugDrugInteraction)
MERGE (ddi)-[r:HAS_DDI_EFFECT]->(effect) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:HAS_EFFECT]->(effect:PhysiologicalEffect)
MERGE (effect)-[r:IS_EFFECT_OF]->(a) SET r.inferred = true;

MATCH (effect:PhysiologicalEffect)-[:IS_EFFECT_OF]->(a:PharmacologicalEntity)
MERGE (a)-[r:HAS_EFFECT]->(effect) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:HAS_METABOLITE]->(b:PharmacologicalEntity)
WHERE a <> b
MERGE (b)-[r:IS_METABOLITE_OF]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_METABOLITE_OF]->(b:PharmacologicalEntity)
WHERE a <> b
MERGE (b)-[r:HAS_METABOLITE]->(a) SET r.inferred = true;

MATCH (ddi:DrugDrugInteraction)-[:HAS_OBJECT]->(a:PharmacologicalEntity)
MERGE (a)-[r:IS_OBJECT_IN]->(ddi) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_OBJECT_IN]->(ddi:DrugDrugInteraction)
MERGE (ddi)-[r:HAS_OBJECT]->(a) SET r.inferred = true;

MATCH (a:PharmacokineticProcess)-[:HAS_PARAMETER]->(b:PharmacokineticParameter)
MERGE (b)-[r:IS_PARAMETER_OF]->(a) SET r.inferred = true;

MATCH (a:PharmacokineticParameter)-[:IS_PARAMETER_OF]->(b:PharmacokineticProcess)
MERGE (b)-[r:HAS_PARAMETER]->(a) SET r.inferred = true;

MATCH (ddi:DrugDrugInteraction)-[:HAS_PARTICIPANT]->(a:PharmacologicalEntity)
MERGE (a)-[r:IS_PARTICIPANT_IN]->(ddi) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_PARTICIPANT_IN]->(ddi:DrugDrugInteraction)
MERGE (ddi)-[r:HAS_PARTICIPANT]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:HAS_PHARMACOLOGICAL_TARGET]->(target:PharmacologicalTarget)
MERGE (target)-[r:IS_PHARMACOLOGICAL_TARGET_OF]->(a) SET r.inferred = true;

MATCH (target:PharmacologicalTarget)-[:IS_PHARMACOLOGICAL_TARGET_OF]->(a:PharmacologicalEntity)
MERGE (a)-[r:HAS_PHARMACOLOGICAL_TARGET]->(target) SET r.inferred = true;

MATCH (ddi:DrugDrugInteraction)-[:HAS_PRECIPITANT]->(a:PharmacologicalEntity)
MERGE (a)-[r:IS_PRECIPITANT_IN]->(ddi) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_PRECIPITANT_IN]->(ddi:DrugDrugInteraction)
MERGE (ddi)-[r:HAS_PRECIPITANT]->(a) SET r.inferred = true;

MATCH (process:PharmacokineticProcess)-[:HAS_PRODUCT]->(a:PharmacologicalEntity)
MERGE (a)-[r:IS_PRODUCT_OF]->(process) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_PRODUCT_OF]->(process:PharmacokineticProcess)
MERGE (process)-[r:HAS_PRODUCT]->(a) SET r.inferred = true;

MATCH (a)-[:HAS_QUALITY]->(b)
WHERE a <> b
MERGE (b)-[r:IS_QUALITY_OF]->(a) SET r.inferred = true;

MATCH (a)-[:IS_QUALITY_OF]->(b)
WHERE a <> b
MERGE (b)-[r:HAS_QUALITY]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:HAS_ROLE]->(role:DrugRole)
MERGE (role)-[r:IS_ROLE_OF]->(a) SET r.inferred = true;

MATCH (role:DrugRole)-[:IS_ROLE_OF]->(a:ChemicalEntity)
MERGE (a)-[r:HAS_ROLE]->(role) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:HAS_SUBSTRATE]->(a:ChemicalEntity)
  MERGE (a)-[r:IS_SUBSTRATE_OF]->(b) SET r.inferred = true;

MATCH (a:ChemicalEntity)-[:IS_SUBSTRATE_OF]->(b:ProteinEntity)
  MERGE (b)-[r:HAS_SUBSTRATE]->(a) SET r.inferred = true;

MATCH (a)-[:IMPAIRS]->(b)
WHERE a <> b
   MERGE (b)-[r:IS_IMPAIRED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_IMPAIRED_BY]->(b)
WHERE a <> b
   MERGE (b)-[r:IMPAIRS]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:INDUCES]->(b:ProteinEntity)
  MERGE (b)-[r:IS_INDUCED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_INDUCED_BY]->(a:PharmacologicalEntity)
  MERGE (a)-[r:INDUCES]->(b) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:INHIBITS]->(b:ProteinEntity)
  MERGE (b)-[r:IS_INHIBITED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_INHIBITED_BY]->(a:PharmacologicalEntity)
  MERGE (a)-[r:INHIBITS]->(b) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:METABOLIZES]->(a:PharmacologicalEntity)
  MERGE (a)-[r:IS_METABOLISED_BY]->(b) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_METABOLISED_BY]->(b:ProteinEntity)
  MERGE (b)-[r:METABOLIZES]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:MODULATES]->(b:ProteinEntity)
  MERGE (b)-[r:IS_MODULATED_BY]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:IS_MODULATED_BY]->(a:PharmacologicalEntity)
  MERGE (a)-[r:MODULATES]->(b) SET r.inferred = true;

MATCH (p1)-[:PRECEDES]->(p2)
WHERE p1 <> p2
   MERGE (p2)-[r:IS_PRECEDED_BY]->(p1) SET r.inferred = true;

MATCH (p1)-[:IS_PRECEDED_BY]->(p2)
WHERE p1 <> p2
   MERGE (p2)-[r:PRECEDES]->(p1) SET r.inferred = true;

MATCH (a)-[:REGULATES]->(b)
WHERE a <> b
MERGE (b)-[r:IS_REGULATED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_REGULATED_BY]->(b)
WHERE a <> b
MERGE (b)-[r:REGULATES]->(a) SET r.inferred = true;

MATCH (b:ProteinEntity)-[:TRANSPORTS]->(a:PharmacologicalEntity)
  MERGE (a)-[r:IS_TRANSPORTED_BY]->(b) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:IS_TRANSPORTED_BY]->(b:ProteinEntity)
  MERGE (b)-[r:TRANSPORTS]->(a) SET r.inferred = true;

MATCH (a:PharmacologicalEntity)-[:UNDERGOES]->(process:PharmacokineticProcess)
MERGE (process)-[r:IS_UNDERGONE_BY]->(a) SET r.inferred = true;

MATCH (process:PharmacokineticProcess)-[:IS_UNDERGONE_BY]->(a:PharmacologicalEntity)
MERGE (a)-[r:UNDERGOES]->(process) SET r.inferred = true;



// FIRST SET OF 59 RULES

// 1
WITH 1 AS i
MATCH (othery:PharmacologicalEntity)-[r1:ACTIVATES]->(z:ProteinEntity)-[r2:IS_ACTIVATED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 2
WITH 2 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:IS_INHIBITED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 4
WITH 4 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:IS_MODULATED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 6
WITH 6 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:IS_INDUCED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 7
WITH 7 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 8
WITH 8 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INHIBITS]->(z:ProteinEntity)-[r2:IS_INHIBITED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 9
WITH 9 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 10
WITH 10 AS i
MATCH (othery:PharmacologicalEntity)-[r1:IS_TRANSPORTED_BY]->(z:ProteinEntity)-[r2:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 11
WITH 11 AS i
MATCH (othery:PharmacologicalEntity)-[r1:IS_BLOCKED_BY]->(z:ProteinEntity)-[r2:BLOCKS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 12
WITH 12 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INDUCES]->(z:ProteinEntity)-[r2:IS_INDUCED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 14
WITH 14 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INDUCES]->(z:ProteinEntity)-[r2:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 16
WITH 16 AS i
MATCH (othery:PharmacologicalEntity)-[r1:HAS_PHARMACOLOGICAL_TARGET]->(z:ProteinEntity)-[r2:IS_PHARMACOLOGICAL_TARGET_OF]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 17
WITH 17 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 18
WITH 18 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:IS_PHARMACOLOGICAL_TARGET_OF]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 19
WITH 19 AS i
MATCH (othery:PharmacologicalEntity)-[r2:IS_PHARMACOLOGICAL_TARGET_OF]->(z:ProteinEntity)-[r1:INHIBITS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 24
WITH 24 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INDUCES]->(z:ProteinEntity)-[r2:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 26
WITH 26 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:IS_INHIBITED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 28
WITH 28 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 29
WITH 29 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:IS_INDUCED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 31
WITH 31 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:IS_MODULATED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 32
WITH 32 AS i
MATCH (othery:PharmacologicalEntity)-[r1:IS_METABOLISED_BY]->(z:ProteinEntity)-[r2:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 33
WITH 33 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:IS_INHIBITED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 36
WITH 36 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INHIBITS]->(z:ProteinEntity)-[r2:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 37
WITH 37 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:IS_PHARMACOLOGICAL_TARGET_OF]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 41
WITH 41 AS i
MATCH (othery:PharmacologicalEntity)-[r2:INDUCES]->(z:ProteinEntity)-[r1:IS_INHIBITED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 45
WITH 45 AS i
MATCH (othery:PharmacologicalEntity)-[r2:ACTIVATES]->(z:ProteinEntity)-[r1:IS_PHARMACOLOGICAL_TARGET_OF]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 47
WITH 47 AS i
MATCH (othery:PharmacologicalEntity)-[r1:BLOCKS]->(z:ProteinEntity)-[r2:IS_ACTIVATED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 49
WITH 49 AS i
MATCH (othery:PharmacologicalEntity)-[r1:MODULATES]->(z:ProteinEntity)-[r2:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 51
WITH 51 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:IS_MODULATED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 52
WITH 52 AS i
MATCH (othery:PharmacologicalEntity)-[r1:IS_PHARMACOLOGICAL_TARGET_OF]->(z:ProteinEntity)-[r2:INDUCES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 53
WITH 53 AS i
MATCH (othery:PharmacologicalEntity)-[r1:INHIBITS]->(z:ProteinEntity)-[r2:METABOLIZES]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 54
WITH 54 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:TRANSPORTS]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// 58
WITH 58 AS i
MATCH (othery:PharmacologicalEntity)-[r2:BLOCKS]->(z:ProteinEntity)-[r1:IS_INDUCED_BY]->(y:PharmacologicalEntity)
WHERE othery <> y
MERGE (othery)-[new1:MAY_INTERACT_WITH]->(y)
MERGE (y)-[new2:MAY_INTERACT_WITH]->(othery)
SET new1.inferred = true, new2.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(new1.rules,[]) THEN [] ELSE [1] END | 
   SET new1.rules = COALESCE(new1.rules,[]) + i
   SET new2.rules = COALESCE(new2.rules,[]) + i
)
MERGE (y)<-[new3:HAS_PARTICIPANT]-(ddi:DrugDrugInteraction)-[new4:HAS_PARTICIPANT]->(othery)
ON MATCH SET ddi.inferred = true
ON CREATE SET 
   ddi.preferredLabel = CASE WHEN y.preferredLabel < othery.preferredLabel 
   THEN (y.preferredLabel + "/" + othery.preferredLabel + " DDI")
   ELSE (othery.preferredLabel + "/" + y.preferredLabel + " DDI") END,
   ddi.inferred = true
SET new3.inferred = true, new4.inferred = true
FOREACH(ignoreMe in CASE WHEN i IN COALESCE(ddi.ruleset1,[]) THEN [] ELSE [1] END | 
   SET ddi.ruleset1 = COALESCE(ddi.ruleset1,[]) + i
);

// Infer IS_PARTICIPANT_IN from HAS_PARTICIPANT
MATCH (ddi:DrugDrugInteraction)-[r1:HAS_PARTICIPANT]->(drug:PharmacologicalEntity)
WHERE EXISTS(r1.inferred)
MERGE (drug)-[r2:IS_PARTICIPANT_IN]->(ddi)
SET r2.inferred = true;

// Delete possible duplicates
MATCH ()-[r:MAY_INTERACT_WITH]-()
WHERE EXISTS(r.inferred) AND SIZE(r.rules) > 0
WITH r, r.rules AS numbers
       WITH r, [i in range(0, SIZE(numbers)-1)
               WHERE i = 0 OR numbers[i] <> numbers[i-1] | numbers[i] ] AS newList
SET r.rules = newList;

















// Inverse relationships after internal DDI inference
MATCH (a)-[:DECREASES]->(b)
WHERE a <> b
   MERGE (b)-[r:IS_DECREASED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_DECREASED_BY]->(b)
WHERE a <> b
   MERGE (b)-[r:DECREASES]->(a) SET r.inferred = true;

MATCH (a)-[:INCREASES]->(b)
WHERE a <> b
MERGE (b)-[r:IS_INCREASED_BY]->(a) SET r.inferred = true;

MATCH (a)-[:IS_INCREASED_BY]->(b)
WHERE a <> b
MERGE (b)-[r:INCREASES]->(a) SET r.inferred = true;


RETURN TIMESTAMP();
