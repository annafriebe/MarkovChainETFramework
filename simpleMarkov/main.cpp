#include <iostream>
#include <thread>
#include <chrono>
#include <random>
#include <pthread.h>
#include <sched.h>

using namespace std;

namespace{
const chrono::milliseconds periodDuration(5);
const int moduloVal = 4711;
const int addVal = 47;
const array<double, 3> trans1 =  {0.7, 0.2, 0.1};
const array<double, 3> trans2 =  {0.5, 0.3, 0.2};
const array<double, 3> trans3 =  {0.5, 0.4, 0.1};

const array<array<double, 3>, 3> transitionMatrix = {trans1, trans2, trans3};

int stateTransition(int previousState){
  const array<double, 3>& transitionProbs = transitionMatrix[previousState];
  int sample = rand()%100;
  double prob = sample/100.0;
  double cumProb=0;
  for (int i=0; i<3; ++i){
    cumProb += transitionProbs[i];
    if (prob < cumProb){
      return i;
    }
  }
  return 2;
}

void task(int& nPeriod, array<int, 100>& calcValues, int& state, int transitionProb){
  state = stateTransition(state);
  switch(state){
  case 0:
    for(int i=0; i<20; ++i){
      for(int j=0; j<10; ++j){
        calcValues[i] = (calcValues[i] + addVal)%moduloVal;
      }
    }
    break;
  case 1:
    for(int i=0; i<50; ++i){
      for(int j=0; j<10; ++j){
        calcValues[i] = (calcValues[i] + addVal)%moduloVal;
      }
    }
    break;
  case 2:
    for(auto& val : calcValues){
      for(int j=0; j<10; ++j){
        val = (val + addVal)%moduloVal;
      }
    }
    break;
  default:
    cerr << "unexpected state" << endl;
  }
  nPeriod++;
}
}

int main(int argc, char *argv[]) {
  array<int, 100> calcValues;
  int nPeriods = 0;
  pthread_t this_thread = pthread_self();
  struct sched_param params;
  params.sched_priority = sched_get_priority_max(SCHED_FIFO);
  int ret = pthread_setschedparam(this_thread, SCHED_FIFO, &params);
  if (ret != 0) {
    cerr << "Unable to set scheduling parameters." << endl;
  }
  else {
    cerr << "Scheduling parameters properly set." << endl;
  }
  int policy = 0;
  ret = pthread_getschedparam(this_thread, &policy, &params);
  if (ret != 0) {
    cerr << "Couldn't retrieve real-time scheduling paramers" << endl;
    return 0;
  }
  
  // Check the correct policy was applied
  if(policy != SCHED_FIFO) {
    cerr << "Scheduling is NOT SCHED_FIFO!" << std::endl;
  } else {
    cerr << "SCHED_FIFO OK" << endl;
  }
  
  // Print thread scheduling priority
  cerr << "Thread priority is " << params.sched_priority << endl;
  std::random_device rd;  //Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd()); //Standard mersenne_twister_engine seeded with rd()
  std::uniform_int_distribution<> initDis(0, moduloVal);
  std::uniform_int_distribution<> transitionDis(0, 99);
  int state = 0;
  
  // set up random starting values
  for(auto& val : calcValues){
    val = initDis(gen);
  }
  std::chrono::steady_clock::time_point next = 
    chrono::steady_clock::now();	
  
  while(nPeriods < 10000){
    task(nPeriods, calcValues, state, transitionDis(gen));
    next += periodDuration;
    std::this_thread::sleep_until(next);
  }
  cerr << "nPeriods: " << nPeriods << endl;
  for(const int& val:calcValues){
    cerr << val << endl; 
  }
  return 0;
}
