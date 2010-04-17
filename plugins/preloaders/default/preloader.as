var preLoader:PreLoader = null;

function getPreLoader() : MovieClip
{
	preLoader = new PreLoader();
	return preLoader;
}

function setPreLoader( progress:Number )
{
	if( preLoader ) {
		preLoader.control.progress.width = progress;
		preLoader.loaderText.text = progress + "%";
	}	
}