FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.0

RUN elasticsearch-plugin install --batch ingest-attachment &&\
    elasticsearch-plugin install --batch analysis-kuromoji &&\
    elasticsearch-plugin install --batch analysis-icu
