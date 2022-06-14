/*
   Copyright (C) 2022 Pascal Heiter
   ----------------------------------------------------------------------------
  This file is part of AMMSoCK.

  AMMSoCK is free software: you can redistribute it and/or modify it under the
  terms of the GNU General Public License as published by the Free Software
  Foundation, either version 3 of the License, or (at your option) any later
  version. AMMSoCK is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
  details. You should have received a copy of the GNU General Public License
  along with AMMSoCK. If not, see <https://www.gnu.org/licenses/>.
*/

// Copyright (C) 2004, 2009 International Business Machines and others.
// All Rights Reserved.
// This code is published under the Eclipse Public License.
//
// $Id: cpp_example.cpp 2005 2011-06-06 12:55:16Z stefan $
//
// Authors:  Carl Laird, Andreas Waechter     IBM    2004-11-05

#include "coin-or/IpIpoptApplication.hpp"
#include "coin-or/IpSolveStatistics.hpp"
#include "ammsockNLP.hpp"
#include "matrix.h"
#include "mex.h"

#include <iostream>

using namespace Ipopt;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  // Create an instance of your nlp...
  SmartPtr<ammsockNLP> mynlp = new ammsockNLP();

  // check arguments
  if (nrhs != 3) {
    std::cerr << "performReduction - Error: Function call is "
                 "performReduction(rpv,init,param).\n";
    return;
  };

  if (mxIsEmpty(prhs[0])) {
    std::cerr << "performReduction - Error: rpv has to be non-empty.\n";
    return;
  }

  if (mxIsEmpty(prhs[1])) {
    std::cerr << "performReduction - Error: init has to be non-empty.\n";
    return;
  }

  if (!mxIsStruct(prhs[2])) {
    std::cerr << "performReduction - Error: param has to be a struct.\n";
    return;
  }

  double *rpv;
  double *init;
  int fieldNumber;
  const size_t *size_rpv, *size_init;

  const mxArray *pm;

  rpv = mxGetPr(prhs[0]);
  init = mxGetPr(prhs[1]);
  pm = prhs[2];

  // get dimension of rpv
  size_rpv = mxGetDimensions(prhs[0]);
  if (size_rpv[1] != NRPV) {
    std::cerr << "performReduction - Error: rpv must have dimension (1," << NRPV
              << ").\n";
    return;
  }

  // get dimension of init
  size_init = mxGetDimensions(prhs[1]);
  if (size_init[1] != (NOP + 1)) {
    std::cerr << "performReduction - Error: init must have dimension (1,"
              << NOP + 1 << ").\n";
    return;
  }

  mxArray *foo;

  // set stepsize for collocation: hcoll
  fieldNumber = mxGetFieldNumber(pm, "hcoll");
  double *hcoll;
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: hcoll field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    hcoll = mxGetPr(foo);
  }

  // set fixed enthalpy: hfixed
  fieldNumber = mxGetFieldNumber(pm, "hfixed");
  double *hfixed;
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: hfixed field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    hfixed = mxGetPr(foo);
  }

  // set scaling parameter: scale
  fieldNumber = mxGetFieldNumber(pm, "scale");
  double *scale;
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: scale field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    scale = mxGetPr(foo);
  }

  // set constants for mass conservation: atomCons
  fieldNumber = mxGetFieldNumber(pm, "atomCons");
  double *atomCons;
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: atomCons field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    atomCons = mxGetPr(foo);
  }

  // set maximum of iterations: maxit
  fieldNumber = mxGetFieldNumber(pm, "maxit");
  double *maxit_ptr;
  int maxit = 10; // default value of maxit = 10.
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: maxit field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    maxit_ptr = mxGetPr(foo);
    maxit = (int)maxit_ptr[0];
  }

  // set option of exact hessian of the lagrainian: exactHessian
  fieldNumber = mxGetFieldNumber(pm, "exactHessian");
  double *exactHessian_ptr;
  int exactHessian = 0; // default without exact hessian
  if (fieldNumber == -1) {
    std::cerr << "performReduction - Error: exactHessian field is empty.\n";
    return;
  } else {
    foo = mxGetFieldByNumber(pm, 0, fieldNumber);
    exactHessian_ptr = mxGetPr(foo);
    exactHessian = (int)exactHessian_ptr[0];
  }

  mynlp->setParameter(rpv, init, hcoll[0], hfixed[0], scale[0], atomCons);

  //   mynlp->checkMethods();
  // return;

  SmartPtr<IpoptApplication> app = IpoptApplicationFactory();

  ApplicationReturnStatus status;
  status = app->Initialize();

  app->Options()->SetStringValue("mu_strategy", "monotone");

  if (exactHessian == 0) {
    app->Options()->SetStringValue("hessian_approximation", "limited-memory");
  } else {
    app->Options()->SetStringValue("hessian_approximation", "exact");
  }

  app->Options()->SetIntegerValue("max_iter", 10000);
  //	app->Options()->SetStringValue("sb","no");
  app->Options()->SetIntegerValue("print_level", 0);

  if (status != Solve_Succeeded) {
    std::cerr << std::endl << std::endl << "*** Error during initialization!\n";
  }

  double *result;
  plhs[2] = mxCreateDoubleMatrix(1, NOP + 1, mxREAL);
  result = mxGetPr(plhs[2]);

  double res[NOP + 1];

  int it = 1;

  status = app->OptimizeTNLP(mynlp);
  while ((status != Solve_Succeeded) &&
         (status != Solved_To_Acceptable_Level) && (it <= maxit)) {
    status = app->ReOptimizeTNLP(mynlp);
    it++;
  }
  mynlp->getSolution(res);

  if ((status != Solve_Succeeded) && (status != Solved_To_Acceptable_Level)) {

  } else {
    // write solution
    for (int i = 0; i < NOP + 1; ++i) {
      result[i] = res[i];
    }
  }

  double *exitstatus;
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  exitstatus = mxGetPr(plhs[0]);

  exitstatus[0] = status;

  double *itptr;
  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  itptr = mxGetPr(plhs[1]);
  itptr[0] = it;

  return;
}
