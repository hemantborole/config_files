#!/usr/bin/env ruby

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase.HBaseConfiguration
import org.apache.hadoop.hbase.client.Get
import org.apache.hadoop.hbase.client.HTable
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.client.Result
import org.apache.hadoop.hbase.client.ResultScanner
import org.apache.hadoop.hbase.client.Scan
import org.apache.hadoop.hbase.util.Bytes

table = HTable.new("presence_crawl")
scan = Scan.new
scanner = table.getScanner(scan)

scanner.each { |rr|
  r = Bytes.toString(rr.value)
  j = JSON.parse(r)
}
