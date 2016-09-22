//
//  CGRectHelper.swift
//
//  Created by Maximus McCann on 9/28/14.
//
//  MIT License.  Use at your own risk.

import UIKit

private func rX(r: CGRect) -> CGFloat { return r.origin.x }
private func rY(r: CGRect) -> CGFloat { return r.origin.y }
private func rH(r: CGRect) -> CGFloat { return r.size.width }
private func rW(r: CGRect) -> CGFloat { return r.size.height }

func CGAddSizeToSize(s1: CGSize, _ s2: CGSize) -> CGSize { return CGSizeMake(s1.width + s2.width, s1.height + s2.height) }
func + (s1: CGSize, s2: CGSize) -> CGSize { return CGAddSizeToSize(s1,s2) }
func += (inout s1: CGSize, s2: CGSize) { s1 = CGAddSizeToSize(s1,s2) }
func CGSubSizeFromSize(s1: CGSize, _ s2: CGSize) -> CGSize { return CGSizeMake(s1.width - s2.width, s1.height - s2.height) }
func - (s1: CGSize, s2: CGSize) -> CGSize { return CGSubSizeFromSize(s1,s2) }
func -= (inout s1: CGSize, s2: CGSize) { s1 = CGSubSizeFromSize(s1,s2) }

func CGAddPointToPoint(p1: CGPoint, _ p2: CGPoint) -> CGPoint { return CGPointMake(p1.x + p2.x, p1.y + p2.y) }
func + (p1: CGPoint, p2: CGPoint) -> CGPoint { return CGAddPointToPoint(p1, p2) }
func += (inout p1: CGPoint, p2: CGPoint) { p1 = CGAddPointToPoint(p1, p2) }
func CGSubPointFromPoint(p1: CGPoint, _ p2: CGPoint) -> CGPoint { return CGPointMake(p1.x - p2.x, p1.y - p2.y) }
func - (p1: CGPoint, p2: CGPoint) -> CGPoint { return CGSubPointFromPoint(p1, p2) }
func -= (inout p1: CGPoint, p2: CGPoint) { p1 = CGSubPointFromPoint(p1, p2) }

func CGRectSetWidth(r: CGRect, _ w: CGFloat) -> CGRect { return CGRectMake(rX(r), rY(r), w, rH(r)) }
func CGRectAddWidth(r: CGRect, _ w: CGFloat) -> CGRect { return CGRectSetWidth(r, rW(r) + w) }

func CGRectSetHeight(r: CGRect, _ h: CGFloat) -> CGRect { return CGRectMake(rX(r), rY(r), rW(r), h) }
func CGRectAddHeight(r: CGRect, _ h: CGFloat) -> CGRect { return CGRectSetHeight(r, rH(r) + h) }

func CGRectSetSize(r: CGRect, _ s: CGSize) -> CGRect { return CGRectMake(rX(r), rY(r), s.width, s.height) }
func CGRectAddSize(r: CGRect, _ s: CGSize) -> CGRect { return CGRectSetSize(r, CGAddSizeToSize(r.size, s)) }
func CGRectSubSize(r: CGRect, _ s: CGSize) -> CGRect { return CGRectSetSize(r, CGSubSizeFromSize(r.size, s)) }

func CGRectSetX(r: CGRect, _ x: CGFloat) -> CGRect { return CGRectMake(x, rY(r), rW(r), rH(r)) }
func CGRectAddX(r: CGRect, _ x: CGFloat) -> CGRect { return CGRectSetX(r, rX(r) + x) }

func CGRectSetY(r: CGRect, _ y: CGFloat) -> CGRect { return CGRectMake(rX(r), y, rW(r), rH(r)) }
func CGRectAddY(r: CGRect, _ y: CGFloat) -> CGRect { return CGRectSetY(r, rY(r) + y) }

func CGRectSetOrigin(r: CGRect, _ o: CGPoint) -> CGRect { return CGRectMake(o.x, o.y, rW(r), rH(r)) }
func CGRectAddOrigin(r: CGRect, _ o: CGPoint) -> CGRect { return CGRectSetOrigin(r, CGAddPointToPoint(r.origin, o)) }
func CGRectSubOrigin(r: CGRect, _ o: CGPoint) -> CGRect { return CGRectSetOrigin(r, CGSubPointFromPoint(r.origin, o)) }

func CGRectRightX(r: CGRect) -> CGFloat { return rX(r) + rW(r) }
func CGRectBottomY(r: CGRect) -> CGFloat { return rY(r) + rH(r) }
