require 'yaml/store'

module SimpleHttpMonitor
  ##
  # Class: Store
  #
  # Implements mechanism of persisting of
  # an object.
  class Store

    # Saves objects
    #
    # Params:
    #   - obj {Object} to save
    #   - path {String} location in storage to save objects to.
    def save(obj, path=nil)
      path = (path || obj.class).to_s
      store.transaction do
        store[path] = obj
      end
    end

    # Loads object from storage
    #
    # Params:
    #   - path {String} to load object from
    def load(path)
      store.transaction do
        store[path.to_s]
      end
    end

    private

    # Initializes new instance
    #
    # Params:
    #   - store_dir {String} with path to storage directory
    def initialize(store_dir)
      @store_dir = store_dir
    end

    def store_file
      File.join(@store_dir, 'storage.yml')
    end

    def store
      @store ||= YAML::Store.new(store_file)
    end
  end
end
