require 'couchbase'

module Couchbase
  class Bucket
    # IMPORTANT:
    #   This method assumes that the doc you pass in is unmodified.
    #   Any unsaved changes to it will be discarded.
    #
    #   It loads a clean copy of the doc and passes it to the given
    #   block, which should apply changes to that document that can
    #   be retried from scratch multiple times until they are successful.
    #
    #   This method will return the final state of the saved doc.
    #   The caller shoudl use this afterward, instead of the object it has
    #   passed in to the method call.
    #
    def update_with_retry(key, doc, &block)
      begin
        doc, flags, cas = get(key, :extended => true)
        yield doc
        set(key, doc, :cas => cas)
      rescue Couchbase::Error::KeyExists
        retry
      end
      doc
    end
  end
end
