
#include "GaussianMixtureModels.h"

namespace GRT {
    
//Register the GaussianMixtureModels class with the Clusterer base class
RegisterClustererModule< GaussianMixtureModels > GaussianMixtureModels::registerModule("GaussianMixtureModels");

//Constructor,destructor
GaussianMixtureModels::GaussianMixtureModels(const UINT numClusters,const UINT minNumEpochs,const UINT maxNumEpochs,const double minChange){
    
    this->numClusters = numClusters;
    this->minNumEpochs = minNumEpochs;
    this->maxNumEpochs = maxNumEpochs;
    this->minChange = minChange;
    
    numTrainingSamples = 0;
    numTrainingIterationsToConverge = 0;
    trained = false;
    
    clustererType = "GaussianMixtureModels";
    debugLog.setProceedingText("[DEBUG GaussianMixtureModels]");
    errorLog.setProceedingText("[ERROR GaussianMixtureModels]");
    trainingLog.setProceedingText("[TRAINING GaussianMixtureModels]");
    warningLog.setProceedingText("[WARNING GaussianMixtureModels]");
}

GaussianMixtureModels::GaussianMixtureModels(const GaussianMixtureModels &rhs){
    
    clustererType = "GaussianMixtureModels";
    debugLog.setProceedingText("[DEBUG GaussianMixtureModels]");
    errorLog.setProceedingText("[ERROR GaussianMixtureModels]");
    trainingLog.setProceedingText("[TRAINING GaussianMixtureModels]");
    warningLog.setProceedingText("[WARNING GaussianMixtureModels]");
    
    if( this != &rhs ){
        
        this->numTrainingSamples = rhs.numTrainingSamples;
        this->loglike = rhs.loglike;
        this->mu = rhs.mu;
        this->resp = rhs.resp;
        this->frac = rhs.frac;
        this->lndets = rhs.lndets;
        this->det = rhs.det;
        this->sigma = rhs.sigma;
        this->invSigma = rhs.invSigma;
        
        //Clone the Clusterer variables
        copyBaseVariables( (Clusterer*)&rhs );
    }
    
}

GaussianMixtureModels::~GaussianMixtureModels(){
}

GaussianMixtureModels& GaussianMixtureModels::operator=(const GaussianMixtureModels &rhs){
    
    if( this != &rhs ){
        
        this->numTrainingSamples = rhs.numTrainingSamples;
        this->loglike = rhs.loglike;
        this->mu = rhs.mu;
        this->resp = rhs.resp;
        this->frac = rhs.frac;
        this->lndets = rhs.lndets;
        this->det = rhs.det;
        this->sigma = rhs.sigma;
        this->invSigma = rhs.invSigma;
        
        //Clone the Clusterer variables
        copyBaseVariables( (Clusterer*)&rhs );
    }
    
    return *this;
}
    
bool GaussianMixtureModels::deepCopyFrom(const Clusterer *clusterer){
    
    if( clusterer == NULL ) return false;
    
    if( this->getClustererType() == clusterer->getClustererType() ){
        //Clone the GaussianMixtureModels values
        GaussianMixtureModels *ptr = (GaussianMixtureModels*)clusterer;
        
        this->numTrainingSamples = ptr->numTrainingSamples;
        this->loglike = ptr->loglike;
        this->mu = ptr->mu;
        this->resp = ptr->resp;
        this->frac = ptr->frac;
        this->lndets = ptr->lndets;
        this->det = ptr->det;
        this->sigma = ptr->sigma;
        this->invSigma = ptr->invSigma;
        
        //Clone the Clusterer variables
        return copyBaseVariables( clusterer );
    }
    return false;
}
    
bool GaussianMixtureModels::reset(){
    
    Clusterer::reset();
    
    numTrainingSamples = 0;
    loglike = 0;
    
    return true;
}

bool GaussianMixtureModels::clear(){
    
    Clusterer::clear();
    
    numTrainingSamples = 0;
    loglike = 0;
	mu.clear();
	resp.clear();
	frac.clear();
	lndets.clear();
	det.clear();
	sigma.clear();
	invSigma.clear();
    
    return true;
}

bool GaussianMixtureModels::train(MatrixDouble data){
    return trainInplace( data );
}

bool GaussianMixtureModels::trainInplace(MatrixDouble &data){
    
    trained = false;
    
    //Clear any previous training results
    det.clear();
    invSigma.clear();
    numTrainingIterationsToConverge = 0;
    
    if( data.getNumRows() == 0 ){
        errorLog << "trainInplace(MatrixDouble &data) - Training Failed! Training data is empty!" << endl;
        return false;
    }
    
    //Resize the variables
    numTrainingSamples = data.getNumRows();
    numInputDimensions = data.getNumCols();
    
    //Resize mu and resp
    mu.resize(numClusters,numInputDimensions);
    resp.resize(numTrainingSamples,numClusters);
    
    //Resize sigma
    sigma.resize(numClusters);
    for(UINT k=0; k<numClusters; k++){
        sigma[k].resize(numInputDimensions,numInputDimensions);
    }
    
    //Resize frac and lndets
    frac.resize(numClusters);
    lndets.resize(numClusters);
    
    //Scale the data if needed
    ranges = data.getRanges();
    if( useScaling ){
        for(UINT i=0; i<numTrainingSamples; i++){
            for(UINT j=0; j<numInputDimensions; j++){
                data[i][j] = scale(data[i][j],ranges[j].minValue,ranges[j].maxValue,0,1);
            }
        }
    }
    
    //Pick K random starting points for the inital guesses of Mu
    Random random;
    vector< UINT > randomIndexs(numTrainingSamples);
    for(UINT i=0; i<numTrainingSamples; i++) randomIndexs[i] = i;
    for(UINT i=0; i<numClusters; i++){
        SWAP(randomIndexs[ i ],randomIndexs[ random.getRandomNumberInt(0,numTrainingSamples) ]);
    }
    for(UINT k=0; k<numClusters; k++){
        for(UINT n=0; n<numInputDimensions; n++){
            mu[k][n] = data[ randomIndexs[k] ][n];
        }
    }
    
    //Setup sigma and the uniform prior on P(k)
    for(UINT k=0; k<numClusters; k++){
        frac[k] = 1.0/double(numClusters);
        for(UINT i=0; i<numInputDimensions; i++){
            for(UINT j=0; j<numInputDimensions; j++) sigma[k][i][j] = 0;
            sigma[k][i][i] = 1.0e-2;   //Set the diagonal to a small number
        }
    }
    
    loglike = 0;
    bool keepGoing = true;
    double change = 99.9e99;
    UINT numIterationsNoChange = 0;
    VectorDouble u(numInputDimensions);
	VectorDouble v(numInputDimensions);
    
    while( keepGoing ){
        
        //Run the estep
        if( estep( data, u, v, change ) ){
            
            //Run the mstep
            mstep( data );
        
            //Check for convergance
            if( fabs( change ) < minChange ){
                if( ++numIterationsNoChange >= minNumEpochs ){
                    keepGoing = false;
                }
            }else numIterationsNoChange = 0;
            if( ++numTrainingIterationsToConverge >= maxNumEpochs ) keepGoing = false;
            
        }else{
            errorLog << "trainInplace(MatrixDouble &data) - Estep failed at iteration " << numTrainingIterationsToConverge << endl;
            return false;
        }
    }
    
    //Compute the inverse of sigma and the determinants for prediction
    if( !computeInvAndDet() ){
        det.clear();
        invSigma.clear();
        errorLog << "trainInplace(MatrixDouble &data) - Failed to compute inverse and determinat!" << endl;
        return false;
    }
    
    //Flag that the model was trained
    trained = true;
    
    return true;
}

bool GaussianMixtureModels::trainInplace(LabelledClassificationData &trainingData){
    MatrixDouble data = trainingData.getDataAsMatrixDouble();
    return trainInplace( data );
}

bool GaussianMixtureModels::trainInplace(UnlabelledClassificationData &trainingData){
    MatrixDouble data = trainingData.getDataAsMatrixDouble();
    return trainInplace( data );
}
    
bool GaussianMixtureModels::saveModelToFile(string filename) const{
    
    std::fstream file;
    file.open(filename.c_str(), std::fstream::out);
    
    if( !file.is_open() ){
        errorLog << "saveModelToFile(string filename) - Failed to open file!" << endl;
        return false;
    }
    
    if( !saveModelToFile( file ) ){
        file.close();
        return false;
    }
    
    file.close();
    
    return true;
}
    
bool GaussianMixtureModels::saveModelToFile(fstream &file) const{
    
    if( !file.is_open() ){
        errorLog << "saveModelToFile(string filename) - Failed to open file!" << endl;
        return false;
    }
    
    file << "GRT_GAUSSIAN_MIXTURE_MODELS_FILE_V1.0\n";
    
    if( !saveClustererSettingsToFile( file ) ){
        errorLog << "saveModelToFile(fstream &file) - Failed to save cluster settings to file!" << endl;
        return false;
    }
    
    if( trained ){
        file << "Mu:\n";
        for(UINT k=0; k<numClusters; k++){
            for(UINT n=0; n<numInputDimensions; n++){
                file << mu[k][n] << "\t";
            }
            file << endl;
        }
        
        file << "Sigma:\n";
        for(UINT k=0; k<numClusters; k++){
            for(UINT i=0; i<numInputDimensions; i++){
                for(UINT j=0; j<numInputDimensions; j++){
                    file << sigma[k][i][j] << "\t";
                }
            }
            file << endl;
        }
        
        file << "InvSigma:\n";
        for(UINT k=0; k<numClusters; k++){
            for(UINT i=0; i<numInputDimensions; i++){
                for(UINT j=0; j<numInputDimensions; j++){
                    file << invSigma[k][i][j] << "\t";
                }
            }
            file << endl;
        }
        
        file << "Det:\n";
        for(UINT k=0; k<numClusters; k++){
            file << det[k] << endl;
        }
    }
    
    return true;
    
}

bool GaussianMixtureModels::loadModelFromFile(string filename){
    
    std::fstream file;
    string word;
    file.open(filename.c_str(), std::ios::in);
    
    if(!file.is_open()){
        errorLog << "loadModelFromFile(string filename) - Failed to open file!" << endl;
        return false;
    }
    
    if( !loadModelFromFile( file ) ){
        file.close();
        return false;
    }
    
    file.close();
    
    return true;
    
}

bool GaussianMixtureModels::loadModelFromFile(fstream &file){
    
    //Clear any previous model
    clear();
    
    string word;
    file >> word;
    if( word != "GRT_GAUSSIAN_MIXTURE_MODELS_FILE_V1.0" ){
        return false;
    }
    
    if( !loadClustererSettingsFromFile( file ) ){
        errorLog << "loadModelFromFile(fstream &file) - Failed to load cluster settings from file!" << endl;
        return false;
    }
    
    //Load the model
    if( trained ){
        
        //Setup the memory
        mu.resize(numClusters, numInputDimensions);
        sigma.resize(numClusters);
        invSigma.resize(numClusters);
        det.resize(numClusters);
        
        //Load mu
        file >> word;
        if( word != "Mu:" ){
            clear();
            errorLog << "loadModelFromFile(fstream &file) - Failed to load Mu!" << endl;
            return false;
        }
        for(UINT k=0; k<numClusters; k++){
            for(UINT n=0; n<numInputDimensions; n++){
                file >> mu[k][n];
            }
        }
        
        //Load Sigma
        file >> word;
        if( word != "Sigma:" ){
            clear();
            errorLog << "loadModelFromFile(fstream &file) - Failed to load Sigma!" << endl;
            return false;
        }
        for(UINT k=0; k<numClusters; k++){
            sigma[k].resize(numInputDimensions, numInputDimensions);
            for(UINT i=0; i<numInputDimensions; i++){
                for(UINT j=0; j<numInputDimensions; j++){
                    file >> sigma[k][i][j];
                }
            }
        }
        
        //Load InvSigma
        file >> word;
        if( word != "InvSigma:" ){
            clear();
            errorLog << "loadModelFromFile(fstream &file) - Failed to load InvSigma!" << endl;
            return false;
        }
        for(UINT k=0; k<numClusters; k++){
            invSigma[k].resize(numInputDimensions, numInputDimensions);
            for(UINT i=0; i<numInputDimensions; i++){
                for(UINT j=0; j<numInputDimensions; j++){
                    file >> invSigma[k][i][j];
                }
            }
        }
        
        //Load Det
        file >> word;
        if( word != "Det:" ){
            clear();
            errorLog << "loadModelFromFile(fstream &file) - Failed to load Det!" << endl;
            return false;
        }
        for(UINT k=0; k<numClusters; k++){
            file >> det[k];
        }
        
    }
    
    return true;
}

bool GaussianMixtureModels::estep( const MatrixDouble &data, VectorDouble &u, VectorDouble &v, double &change ){

	double tmp,sum,max,oldloglike;
	for(UINT j=0; j<numInputDimensions; j++) u[j] = v[j] = 0;

	oldloglike = loglike;

	for(UINT k=0; k<numClusters; k++){
		Cholesky cholesky( sigma[k] );
		if( !cholesky.getSuccess() ){ return false; }
		lndets[k] = cholesky.logdet();

		for(UINT i=0; i<numTrainingSamples; i++){
			for(UINT j=0; j<numInputDimensions; j++) u[j] = data[i][j] - mu[k][j];
			if( !cholesky.elsolve(u,v) ){ return false; }
			sum=0;
			for(UINT j=0; j<numInputDimensions; j++) sum += SQR(v[j]);
			resp[i][k] = -0.5*(sum + lndets[k]) + log(frac[k]);
		}
	}

	//Compute the overall likelihood of the entire estimated paramter set
	loglike = 0;
	for(UINT i=0; i<numTrainingSamples; i++){
		sum=0;
		max = -99.9e99;
		for(UINT k=0; k<numClusters; k++) if( resp[i][k] > max ) max = resp[i][k];
		for(UINT k=0; k<numClusters; k++) sum += exp( resp[i][k]-max );
		tmp = max + log( sum );
		for(UINT k=0; k<numClusters; k++) resp[i][k] = exp( resp[i][k] - tmp );
		loglike += tmp;
	}
    
    change = (loglike - oldloglike);

	return true;
}

bool GaussianMixtureModels::mstep( const MatrixDouble &data ){

	double wgt, sum;
	for(UINT k=0; k<numClusters; k++){
		wgt = 0.0;
		for(UINT m=0; m<numTrainingSamples; m++) wgt += resp[m][k];
		frac[k] = wgt/double(numTrainingSamples);
		for(UINT n=0; n<numInputDimensions; n++){
			sum = 0;
			for(UINT m=0; m<numTrainingSamples; m++) sum += resp[m][k] * data[m][n];
			mu[k][n] = sum/wgt;
			for(UINT j=0; j<numInputDimensions; j++){
				sum = 0;
				for(UINT m=0; m<numTrainingSamples; m++){
					sum += resp[m][k] * (data[m][n]-mu[k][n]) * (data[m][j]-mu[k][j]);
				}
				sigma[k][n][j] = sum/wgt;
			}
		}
	}
    
    return true;

}

inline void GaussianMixtureModels::SWAP(UINT &a,UINT &b){
	UINT temp = b;
	b = a;
	a = temp;
}

bool GaussianMixtureModels::computeInvAndDet(){

	det.resize(numClusters);
	invSigma.resize(numClusters);

	for(UINT k=0; k<numClusters; k++){
		LUDecomposition lu(sigma[k]);
		if( !lu.inverse( invSigma[k] ) ){
            errorLog << "computeInvAndDet() - Matrix inversion failed for cluster " << k+1 << endl;
            return false;
        }
		det[k] = lu.det();
	}

    return true;

}

}//End of namespace GRT
