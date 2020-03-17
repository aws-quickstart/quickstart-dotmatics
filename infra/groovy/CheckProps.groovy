class CheckProps {
   static void main(String[] args) {

      Properties tmpProperties = new Properties() {
         // It is used for sorting keys when storing properties
         @Override
         public synchronized Enumeration<Object> keys() {
            return Collections.enumeration(new TreeSet<Object>(super.keySet()));
         }
      }

      def tmpFile = new File( "/tmp/browser.properties" ) //  /tmp/dotmatics/config/browser.properties

      tmpProperties.load(tmpFile.newReader())

      def keys = tmpProperties.keySet()

      for(def key : keys) {
         def value = tmpProperties[key]
         if (key.contains('db.dba.user')) {
            if (value == null || "".equals(value.trim())) {
               println "[WARN] db.dba.user is null."
               println "[INFO] Set db.dba.user=SYSTEM"
               tmpProperties[key] = "SYSTEM"
            }
         }

      }
      tmpProperties.store(tmpFile.newWriter(), null)
   }


}
