public class ClientCredentialsAuth extends Auth.AuthProviderPluginClass {
    private String metadataApiName = 'REPLACE YOUR CUSTOM METADATA TYPE eg custom__mdt';
    private String callbackUrl = 'REPLACE YOUR CALL BACKURL, YOU CAN FIND IT IN THE AUTH. PROVIDER CONFIG, SALESFORCE CONFIGURATION SECTION';
    private string tokenEndpoint = 'REPLACE YOUR TOKEN END POINT';
    private string clientId = 'REPLACE THE CLIENT ID';
    private string clientSecret = 'REPLACE THE CLIENT SECRET';
    private String tokenType = 'REPLACE THE TOKEN TYPE Bearer/secret/....';
    private String authProviderName = ' REPLACE YOUR AUTH PROVIDER NAME';
  
    public  String getCustomMetadataType() {
        return metadataApiName;
    }

   //This covers the Steps 1 to 5 of Authorisation grant flow
    public  PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
       
        //State is needed for the flow to function
        //https://salesforce.stackexchange.com/questions/224231/salesforce-no-oauth-state-state-not-valid
        callbackUrl+= + '?state=' + stateToPropagate;

        return new PageReference(callbackUrl);
    }
 
    //From Step 6 , Pass in the client id and secret to get the access token
    public  Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state) {
               
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&grant_type=client_credentials';

        request.setBody(body);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
               
        return new Auth.AuthProviderTokenResponse(authProviderName, responseWrapper.access_token, null, state.queryParameters.get('state'));
    }

  
    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        //custom refresh flow
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        request.setMethod('POST');

        String body = 'client_id='+clientId;
        body+='&client_secret='+clientSecret;
        body+='&grant_type=client_credentials';

        request.setBody(body);

        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
       
        return new Auth.OAuthRefreshResult(responseWrapper.access_token, tokenType);
    }

   //Return fake user, client credentials auth flow is not for a user
    public Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
       
        return new Auth.UserData('fakeId', 'first', 'last', 'full', 'email', 'link', null, null, null, null, null);
    }
  
    public class ResponseWrapper {
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}
