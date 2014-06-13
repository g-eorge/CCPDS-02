/**
 * Takes tsv row vectors from stdin, computes the centroid, 
 * then computes similarity to the centroid.
 */

#include <algorithm>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include <map>
#include <string>
#include <cmath>
#include <chrono>
#include <cassert>

using namespace std;

/** Data for each row */
struct row {
  static int cols;
  string id;
  vector<double> vec;
};
int row::cols = 392;

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

string str(vector<double> a) {
  ostringstream os;
  os << fixed << setprecision(2);

  for(vector<double>::size_type i = 0; i < a.size(); i++) {
    if (i > 0) os << '\t';
    os << a[i];
  }

  os << endl;
  return os.str();
}

/** Turn a row struct into a string */
string str(const row &r) {
  ostringstream os;
  os << fixed << r.id;
  os << '\t' << str(r.vec);
  os << endl;
  return os.str();
}

/** Output n most different pairs */
void display(vector<pair<string,double>> &vec, int n) {
  int len = vec.size();
  char tab = '\t';
  clog << fixed << setprecision(2);
  clog << "Most similar:" << endl;
  for(vector<pair<string,double>>::size_type i = 0; i != n; i++) {
    clog << vec[i].first << tab << vec[i].second << endl;
  }
  clog << endl << "Least similar:" << endl;
  for(vector<pair<string,double>>::size_type i = len-n; i != len; i++) {
    clog << vec[i].first << tab << vec[i].second << endl;
  }
}

/** Output n least similar to csv */
void to_csv(vector<pair<string,double>> &vec, int n) {
  int len = vec.size();
  char comma = ',';
  // cout << fixed << setprecision(2);
  for(vector<pair<string,double>>::size_type i = len-n; i != len; i++) {
    // cout << vec[i].first << comma << vec[i].second << endl;
    cout << vec[i].first << endl;
  }
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
  if (done == 0)
    clog << fixed << setprecision(0) << size << " to process..." << endl;
  float completed = 100 * done / size;
  // Hide and show the cursor with DECTCEM (DEC text cursor enable mode)
  clog << "\e[?25l" << fixed << setprecision(0) << completed << "%\r" << "\e[?25h";
}

/** Compute similarity between each vector and the centroid */
void similarity(vector<row> &matrix, vector<double> &centroid, map<string,double> &sims) {
  int done = 0;
  int size = matrix.size();
  for (auto &row : matrix) {
    sims.insert(pair<string,double>(row.id, euclidean(row.vec, centroid)));
    // progress(size, done);
    done++;
  }
}

/** Convert a map to a vector for sorting */
void map_to_vector(map<string,double> &m, vector<pair<string,double>> &vec) {
  vec.reserve(m.size());
  for (auto &e : m) {
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

double update_avg(double new_datum, double current_avg, int num_datums) {
  return (new_datum + (num_datums * current_avg)) / (num_datums + 1);
}

void average(vector<row> &matrix, vector<double> &centroid) {
  int numrows = 0;
  for (auto &r : matrix) {
    cout << str(centroid) << endl;
    for (vector<double>::size_type i = 0; i != centroid.size(); i++) {
      cout << r.vec[i] << " ";
      // centroid[i] = (r.vec[i] + (numrows * centroid[i])) / (numrows + 1);
      centroid[i] = update_avg(r.vec[i], centroid[i], numrows);
    }
    cout << endl;
    numrows++;
  }
}

void test() {
  row::cols = 4;
  vector<double> centroid(row::cols-1);
  vector<row> matrix;
  vector<double> v1({0, 1, 2});
  vector<double> v2({0, 1, 2});
  vector<double> v3({0, 2, 3});
  vector<double> v4({2, 0, 4});
  vector<double> v5({2, -1});
  vector<double> v6({-2, 2});

  row r1;
  r1.id = "row1";
  r1.vec = v1;
  matrix.push_back(r1);

  row r2;
  r2.id = "row2";
  r2.vec = v2;
  matrix.push_back(r2);

  row r3;
  r3.id = "row3";
  r3.vec = v3;
  matrix.push_back(r3);

  row r4;
  r4.id = "row4";
  r4.vec = v4;
  matrix.push_back(r4);

  average(matrix, centroid);

  cout << str(centroid) << endl;

  assert(euclidean(v1, v2) == 0);
  assert(euclidean(v5, v6) == 5);

  assert(centroid[0] == 0.5);
  assert(centroid[1] == 1.0);
  assert(centroid[2] == 2.75);
}

int main(int argc, char* argv[]) {

  // test();
  // return 0;

  // Set the number of columns if provided
  if (argc > 1) {
    istringstream ss(argv[1]);
    int x;
    if ((ss >> x) && x > 0) 
      row::cols = x;
  }

  vector<row> matrix;
  vector<double> centroid(row::cols-1);
  int numrows = 0;

  auto start = chrono::steady_clock::now();

  string line;
  while (getline(cin, line)) {
    row r = read_row(line);
    matrix.push_back(r);

    // Calculate the centroid of the vectors
    for (vector<double>::size_type i = 0; i != centroid.size(); i++) {
      centroid[i] = update_avg(r.vec[i], centroid[i], numrows);
    }

    numrows++;
  }

  clog << numrows << " to process. ";
  clog << "Calculated centroid. ";

  // Find the similarity to the centroid
  map<string,double> simsmap;
  similarity(matrix, centroid, simsmap);
  clog << "Calculated similarity. ";

  // Convert from map to a vector so we can sort
  vector<pair<string,double>> simsvec;
  map_to_vector(simsmap, simsvec);
  
  // Sort by similarity
  ranked(simsvec);
  clog << "Sorted." << endl;

  auto end = chrono::steady_clock::now();
  auto diff = end - start;
  clog << "Processed " << simsmap.size() << " items in " << chrono::duration <double, milli> (diff).count() << " ms" << endl;
  clog << endl;

  // Output
  // clog << "Centroid: " << str(centroid) << endl;
  int n = 3;
  display(simsvec, n);
  to_csv(simsvec, n);

  return 0;
}