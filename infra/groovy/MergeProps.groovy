class MergeProps {
   static void main(String[] args) {

      def efsFile = new File( "/tmp/efs/browser.properties" ) //  /efs/data/browser/WEB-INF/browser.properties
      def tmpFile = new File( "/tmp/tmp/browser.properties" ) //  /tmp/dotmatics/config/browser.properties

      Properties efsProperties = new Properties()
      Properties tmpProperties = new Properties() {

         // sort when saving.
         @Override
         public synchronized Enumeration<Object> keys() {
            return Collections.enumeration(new TreeSet<Object>(super.keySet()));
         }
      }

      efsProperties.load(efsFile.newReader())
      tmpProperties.load(tmpFile.newReader())

      def ignoreList = ['auth.passwordexpiry']

      def keys = efsProperties.keySet()

      for(def key : keys)
         if (key.contains('password') && ignoreList.contains(key) == false )
         {
            def value = efsProperties[key]
            tmpProperties[key] = value
         }

      tmpProperties.store(tmpFile.newWriter(), null)

   }


}
