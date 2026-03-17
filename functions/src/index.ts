import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export {processIllustrationRequest} from "./illustrationRequests.js";
