/****************************************************************
Created: 26 Dec 2013
Author: Krishna Tatta (CodeScience)
Purpose : Interface class used for the PRMServiceImpl or PRMMockServiceImpl
Modifications:
******************************************************************/
public interface PRMAPIService {
	HttpResponse execute(String message, String soapAction);
}