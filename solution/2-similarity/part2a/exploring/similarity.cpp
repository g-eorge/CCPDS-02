/**
 * Takes tsv input from standard in in and computes the similarity for each 
 * pair of items using Euclidean Distance.
 */

#include <algorithm>
#include <future>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include <map>
#include <string>
#include <cmath>
#include <chrono>

using namespace std;

// typedef future<double> tmap;
typedef double tmap;

/** Data for each row */
struct row {
  static const int cols = 392;
  string id;
  vector<double> vec;
};

/** Parse a CSV row */
row read_row(const string &line) {
  row r;
  int vec_len = r.cols-1;
  r.vec.reserve(vec_len);
  istringstream is(line);
  is >> r.id;

  for (int i = 0; i < vec_len; i++) {
    double val;
    if (is >> val)
      r.vec.push_back(val);
  }

  return r;
}

/** Turn a row struct into a string */
string str(const row &r) {
  ostringstream os;
  os << fixed << r.id;

  for(vector<double>::size_type i = 0; i != r.vec.size(); i++) {
    os << '\t' << r.vec[i];
  }

  os << endl;
  return os.str();
}

/** Output a vector of rows */
void display(vector<row> &matrix) {
  for(auto it = matrix.begin(); it != matrix.end(); ++it) {
    clog << str(*it);
  }
}

/** Output a vector of pairs */
void display(vector<pair<string,double>> &vec) {
  for(auto it = vec.begin(); it != vec.end(); ++it) {
    clog << fixed << it->first << "\t" << it->second << endl;
  }
}

/** Output n most different pairs */
void display(vector<pair<string,double>> &vec, int n) {
  int len = vec.size();
  char tab = '\t';
  clog << fixed << setprecision(2);
  clog << "Most similar:" << endl;
  for(vector<pair<string,double>>::size_type i = 0; i != n && i != vec.size(); i++) {
    clog << vec[i].first << tab << vec[i].second << endl;
  }
  clog << endl << "Least similar:" << endl;
  for(vector<pair<string,double>>::size_type i = len-1; i != len-1-n && i != 0; i--) {
    clog << vec[i].first << tab << vec[i].second << endl;
  }
}

/** Output n least similar to csv */
void to_csv(vector<pair<string,double>> &vec, int n) {
  int len = vec.size();
  char comma = ',';
  cout << fixed << setprecision(2);
  for(vector<pair<string,double>>::size_type i = len-1; i != len-1-n && i != 0; i--) {
    cout << vec[i].first << comma << vec[i].second << endl;
  }
}

/** The total number of comparisons needed to find all the similarities */
int count(int size) {
  return ((size * size) - size) / 2;
}

/** Compute the Euclidean distance between two vectors */
double euclidean(vector<double> p1, vector<double> p2) {
  double sum = 0;
  for(vector<double>::size_type i = 0; i != p1.size(); i++) {
    double dp = p1[i] - p2[i];
    sum += dp * dp;
  }
  return sqrt(sum);
}

/** Output some progress info */
void progress(int size, int done) {
  float s = count(size);
  if (done == 0)
    clog << fixed << setprecision(0) << s << " to process..." << endl;
  float completed = 100 * done / s;
  // Hide and show the cursor with DECTCEM (DEC text cursor enable mode)
  clog << "\e[?25l" << fixed << setprecision(0) << completed << "%\r" << "\e[?25h";
}

/** Compute similarity between each pair of vectors */
void similarity(vector<row> &matrix, map<string,tmap> &sims) {
  int done = 0;
  int size = matrix.size();
  char tab = '\t';
  for (auto &r1 : matrix) {
    for (auto &r2 : matrix) {
      string key = r1.id + tab + r2.id;
      string revkey = r2.id + tab + r1.id;
      if (r1.id != r2.id && !sims.count(key) && !sims.count(revkey)) {
        // sims.insert(pair<string,tmap>(key,
        //   async(launch::async, euclidean, r1.vec, r2.vec)));
        sims.insert(pair<string,tmap>(key, euclidean(r1.vec, r2.vec)));
        done++;
      }
      progress(size, done);
      if (done >= count(size)) return;
    }
  }
}

/** Convert a map to a vector for sorting */
void map_to_vector(map<string,tmap> &m, vector<pair<string,double>> &vec) {
  vec.reserve(m.size());
  for (auto &e : m) {
    // pair<string,double> p(e.first, e.second.get());
    pair<string,double> p(e.first, e.second);
    vec.push_back(p);
  }
}

/** How to sort the similarities */
bool ordering(const pair<string,double> &a, const pair<string,double> &b) {
  return a.second < b.second;
}

/** Sort in place by similarity */
void ranked(vector<pair<string,double>> &sims) {
  sort(sims.begin(), sims.end(), ordering);
}

int main() {
  vector<row> matrix;

  string line;
  while (getline(cin, line)) {
    row r = read_row(line);
    matrix.push_back(r);
  }

  clog << "Calculating similarity..." << endl;
  auto start = chrono::steady_clock::now();

  map<string,tmap> simsmap;
  similarity(matrix, simsmap);

  vector<pair<string,double>> simsvec;
  map_to_vector(simsmap, simsvec);
  
  auto end = chrono::steady_clock::now();
  auto diff = end - start;
  cout << "Processed " << simsmap.size() << " items in " << chrono::duration <double, milli> (diff).count() << " ms" << endl;

  clog << "Sorting..." << endl << endl;
  ranked(simsvec);

  display(simsvec, 3);

  return 0;
}