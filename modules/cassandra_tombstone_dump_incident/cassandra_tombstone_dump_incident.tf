resource "shoreline_notebook" "cassandra_tombstone_dump_incident" {
  name       = "cassandra_tombstone_dump_incident"
  data       = file("${path.module}/data/cassandra_tombstone_dump_incident.json")
  depends_on = [shoreline_action.invoke_cassandra_gc_check]
}

resource "shoreline_file" "cassandra_gc_check" {
  name             = "cassandra_gc_check"
  input_file       = "${path.module}/data/cassandra_gc_check.sh"
  md5              = filemd5("${path.module}/data/cassandra_gc_check.sh")
  description      = "Misconfigured garbage collector: If the garbage collector in Cassandra is misconfigured, it may not be cleaning up tombstones effectively, leading to an accumulation of tombstones that can impact performance and stability."
  destination_path = "/agent/scripts/cassandra_gc_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cassandra_gc_check" {
  name        = "invoke_cassandra_gc_check"
  description = "Misconfigured garbage collector: If the garbage collector in Cassandra is misconfigured, it may not be cleaning up tombstones effectively, leading to an accumulation of tombstones that can impact performance and stability."
  command     = "`chmod +x /agent/scripts/cassandra_gc_check.sh && /agent/scripts/cassandra_gc_check.sh`"
  params      = []
  file_deps   = ["cassandra_gc_check"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_gc_check]
}

