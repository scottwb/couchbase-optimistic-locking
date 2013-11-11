require 'spec_helper'
require 'couchbase_bucket'

describe Couchbase::Bucket do
  describe "#update_with_retry" do
    before :each do
      @key    = "test-object"
      @client = Couchbase.connect(:bucket => "my_bucket", :hostname => "localhost")
      @client.delete(@key)
      @client.set(@key, {'counter' => 1})
    end

    it "should handle concurrent writers" do
      # Get the doc twice.
      doc1 = @client.get(@key)
      doc2 = @client.get(@key)

      # Increment doc1.
      doc1['counter'] += 1
      @client.set(@key, doc1)

      apply_count = 0
      doc2 = @client.update_with_retry(@key, doc2) do |doc|
        # Count how many times this block gets applied to doc2.
        apply_count += 1

        # The first time we try to apply this block to doc2, 
        # lets update doc1 real quick, to simulate the race condition
        # of doc1 being updated by another client AFTER doc2 was loaded,
        # but BEFORE it was modified and saved.
        if apply_count == 1
          # Increment doc1 again.
          doc1['counter'] += 1
          @client.set(@key, doc1)
        end

        # The meat of the apply block...the increment
        doc['counter'] += 1
      end

      # We expect one collision fail, and one successful retry.
      apply_count.should == 2

      # Re-lookup fresh.
      doc3 = @client.get(@key)
    
      # Now doc1 should be one increment behind, and 2 and 3 should be up to date.
      doc1['counter'].should == 3
      doc2['counter'].should == 4
      doc3['counter'].should == 4
    end
  end
end
