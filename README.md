# Dinto ontology in Neo4j

This is the Neo4j exportation of the DINTO ontology. DINTO is an OWL ontology containing drug-drug interaction (DDI) related information.

# Make it go

In order to import this database, the next steps are to be followed:

1 - Create a brand-new project in Neo4j Desktop.\
2 - Create a local graph within this project with an user and password of your choice, preferably selecting the latest version with format 3.5.x.\
3 - Once this graph is created, press "Manage" button and then, in the upper part of the window, press "Open folder".\
4 - Dump the files DINTO_CSVLint.csv, db_creation_script.cypher and DDI_inferences.cypher onto the "import" directory within the previously opened folder.\
5 - After the dump, back in Neo4j Desktop, start the database and open a terminal and run the following command in the latter, replacing XXXXX with the previously chosen password:

cat import/db_creation_script.cypher | bin/cypher-shell -u neo4j -p XXXXX --format plain

6 - For the execution of the inferences, redo step 4 with the file containing the Cypher representation of the rules:

cat import/DDI_inferences.cypher | bin/cypher-shell -u neo4j -p XXXXX --format plain


The execution of both migration and inference scripts should take about half an hour each. The contents of this upload should work in 3.5.x versions of Neo4j.

# External links

- DINTO ontology: https://github.com/labda/DINTO
- Neo4j Home: https://neo4j.com/
