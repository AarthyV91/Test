trigger AccountCallout on Account (after insert) {

    for (Account a : Trigger.new) {
        
        WebServiceCallout.sendNotification(a.Name, a.BillingCity);
    }

}