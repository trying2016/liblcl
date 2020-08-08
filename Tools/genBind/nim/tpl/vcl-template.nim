#[ 
   The code is automatically generated by the genBind tool. 
   Author: ying32
   https://github.com/ying32  
]#
#{.experimental: "codeReordering".}
##
import lclapi, types
##
type
{{$instName := "Instance"}}
{{/* 基类定义 */}}
{{range $el := .BaseObjects}}
##
  {{$el.ClassName}}*{{if isEmpty $el.BaseClassName}} {.inheritable.}{{end}} = ref object{{if not (isEmpty $el.BaseClassName)}} of {{$el.BaseClassName}}{{end}}
  {{if isEmpty $el.BaseClassName}}  {{$instName}}: pointer{{end}}
{{end}}

{{/* 剩下的类定义 */}}
{{range $el := .Objects}}
{{if not (isBaseObj $el.ClassName)}}
##
  {{if ne $el.ClassName "Exception"}}
  {{$el.ClassName}}* = ref object of {{$el.BaseClassName}}
  {{end}}
{{end}}
{{end}}

{{/* 定义的一些函数 */}}
#---------------------------------------------------------------
##
proc CheckPtr*(obj: TObject): pointer =
  if obj != nil:
    return obj.{{$instName}}
  else:
    return nil
##
## -------------------- 转换对象定义 ------------------------------------------
##
template defaultPointerAs =
  if obj == nil:
    return nil
  new(result)
  result.Instance = obj

{{/* As<xxx>方法定义 */}}
## {{/*这里添加一个强制转换的*/}}
{{range $el := .Objects}}
{{if ne $el.ClassName "Exception"}}proc As{{rmObjectT $el.ClassName}}*(obj: pointer): {{$el.ClassName}} = defaultPointerAs{{end}}{{end}}
##

##
proc Instance*(this: TObject): pointer =
  if this != nil:
    return this.{{$instName}}
  else:
    return nil
##
##
{{/*模板定义*/}}
{{define "getlastPs"}}{{if .LastIsReturn}}: {{$ps := lastParam .Params}}{{covType $ps.Type}}{{end}}{{end}}

{{/*当父类为TObject或者为空时，设置构造函数*/}}
{{define "getFree"}}{{if or (eq . "TObject") (eq . "")}}, Free{{end}}{{end}}

{{/*如果是重载的函数，输出重载函数名，返之输出实际函数*/}}
{{define "getOverloadName"}}{{if .IsOverload}}{{.OverloadName}}{{else}}{{.RealName}}{{end}}{{end}}

{{/*TMenuItem增加的2个成员*/}}
{{define "getMenuItemShortTextMethod"}}
proc ShortCutText*(this: TMenuItem): string =
  return $DShortCutToText(this.ShortCut)
##
proc `ShortCutText=`*(this: TMenuItem, text: string) =
  `ShortCut=`(this, DTextToShortCut(text))
{{end}}

{{/* 开始生成方法 */}}
{{/* 默认的free过程 */}}
template defaultFree(pName) =
  if (this != nil) and (this.Instance != nil):
     pName(this.Instance)
     this.Instance = nil



{{$buff := newBuffer}}

{{range $el := .Objects}}

{{/*不生成异常类，交由Nim自己处理*/}}
{{if ne $el.ClassName "Exception"}}
##
#------------------------- {{$el.ClassName}} -------------------------
{{$className := $el.ClassName}}
##
{{$classN := rmObjectT $className}}



{{range $mm := $el.Methods}}
{{if eq $mm.RealName "Create"}}

proc Free*(this: {{$className}}){{if isBaseMethod $el.ClassName $mm.RealName}} {{end}} = defaultFree: {{$classN}}_Free
##
  {{/* newXXXX  */}}
  {{$buff.Clear}}
  {{$buff.Write "proc New" (rmObjectT $className) "*("}}
  {{range $idx, $ps := $mm.Params}}
    {{if gt $idx 0}}
      {{$buff.Write ", "}}
    {{end}}
    {{$buff.Write $ps.Name ": " (covType2 $ps.Type)}}
  {{end}}
  {{$buff.Writeln "): " $className " ="}}

  {{$buff.Write "  new(result"}}
  {{if not $el.IsComponent}}
    {{$buff.Write ", Free"}}
  {{end}}
  {{$buff.Writeln ")"}}
  {{$buff.Write "  result." $instName " = " $mm.Name "("}}
  {{range $idx, $ps := $mm.Params}}
    {{if gt $idx 0}}
      {{$buff.Write ", "}}
    {{end}}
    {{if isObject $ps.Type}}
      {{$buff.Write "CheckPtr(" $ps.Name ")"}}
    {{else}}
      {{$buff.Write $ps.Name}}
    {{end}}
  {{end}}
  {{$buff.Writeln ")"}}

{{$buff.ToStr}}

{{else if eq $mm.RealName "Free"}}
{{else if $mm.IsStatic}}
##
proc {{$className}}Class*(): TClass = {{$mm.Name}}()
##
{{else}}
{{if not $mm.IsStatic}}
{{/* 累了，不想弄，直接写好的得了 */}}
{{if eq $mm.RealName "TextRect2"}}
##
proc TextRect*(this: TCanvas, Rect: var TRect, Text: string, AOutStr: var string, TextFormat: TTextFormat): int32 =
  var outstr: cstring
  result = Canvas_TextRect2(this.{{$instName}}, Rect, Text, outstr, TextFormat)
  AOutStr = $outstr
{{else if eq $mm.RealName "CreateForm"}}
##
proc CreateForm*[T](this: TApplication, x: var T) =
    new(x)
    x.{{$instName}} = Application_CreateForm(this.{{$instName}}, false)
##
proc CreateForm*(this: TApplication): TForm =
  AsForm(Application_CreateForm(this.{{$instName}}, false))
{{else if eq $mm.RealName "SetOnException"}}
proc `OnException=`*(this: TApplication, AEventId: TExceptionEvent)  =
  lclapi.exceptionProc = AEventId
{{else}}
##
  {{/* 其他方法生成 */}}
  {{$isSetProp := $mm.IsSetter}}
  {{$notProp := not $mm.IsProp}}

  {{$buff.Clear}}
  {{$buff.Write "proc "}}
  {{if $isSetProp}}
    {{$buff.Write "`"}}
  {{end}}

  {{if $mm.IsProp}}
      {{$buff.Write $mm.PropName}}
  {{else if $mm.IsOverload}}
      {{$buff.Write $mm.OverloadName}}
  {{else}}
      {{$buff.Write $mm.RealName}}
  {{end}}

  {{if $isSetProp}}
    {{$buff.Write "=`"}}
  {{end}}
  {{$buff.Write "*(this: " $className}}


  {{range $idx, $ps := $mm.Params}}
    {{if canOutParam $mm $idx}}
      {{if gt $idx 0}}
        {{$buff.Write ", " $ps.Name ": "}}
        {{if $ps.IsVar}}
          {{if not (eq $ps.Flag "nonPtr")}}
            {{$buff.Write "var "}}
          {{end}}
        {{end}}
          {{covType2 $ps.Type|$buff.Write}}
      {{end}}
    {{end}}
  {{end}}
  {{$buff.Write ")"}}

  {{if not (isEmpty $mm.Return)}}
    {{$buff.Write ": " (covType2 $mm.Return)}}
  {{else}}
    {{if .LastIsReturn}}
      {{$buff.Write ": "}}
      {{$ps := lastParam .Params}}
      {{covType $ps.Type|$buff.Write}}
    {{end}}
  {{end}}
  {{if $notProp}}
    {{if isBaseMethod $el.ClassName $mm.RealName}}
      {{$buff.Write " "}}
    {{end}}
  {{else}}
    {{$buff.Write " "}}
  {{end}}
  {{$buff.Writeln " ="}}

  {{/*这里生成不需要var的变量*/}}
  {{range $ips, $ps := $mm.Params}}
    {{if and ($ps.IsVar) (eq $ps.Flag "nonPtr")}}
       {{$buff.Writeln "  var ps" $ips " = " $ps.Name}}
    {{end}}
  {{end}}

  {{$buff.Write "  "}}
  {{if not (isEmpty $mm.Return)}}
    {{$buff.Write "return "}}
    {{if eq $mm.Return "string"}}
      {{$buff.Write "$"}}
    {{end}}
  {{end}}
  {{$buff.Write $mm.Name}}
  {{$buff.Write "(this." $instName}}
  {{range $idx, $ps := $mm.Params}}
    {{if canOutParam $mm $idx}}
      {{if gt $idx 0}}
        {{$buff.Write ", "}}
        {{if isObject $ps.Type}}
          {{$buff.Write "CheckPtr(" $ps.Name ")"}}
        {{else}}
          {{if not (eq $ps.Flag "nonPtr")}}
            {{$buff.Write $ps.Name}}
          {{else}}
            {{$buff.Write "ps" $idx}}
          {{end}}
        {{end}}
      {{end}}
    {{else}}
      {{if $mm.LastIsReturn}}
        {{$buff.Write ", result"}}
      {{end}}
    {{end}}
  {{end}}
  {{$buff.Write ")"}}
  {{if and (not (isEmpty $mm.Return)) (isObject $mm.Return)}}
    {{$buff.Write ".As" (rmObjectT $mm.Return)}}
  {{end}}
  {{$buff.Writeln}}

{{$buff.ToStr}}

{{end}}
{{end}}
{{end}}
{{end}}
{{end}}

{{/*为TMenuItem增加快捷方式的*/}}
{{if eq $el.ClassName "TMenuItem"}}
{{template "getMenuItemShortTextMethod" .}}
{{end}}

{{end}}
##
#------------ threadSync ----------------------
# 
import locks
##
# 线程同步专用回调
var
  syncLock: Lock
##
proc ThreadSync*(fn: TThreadProc) =
  acquire(syncLock) 
  defer:
    release(syncLock)
  threadSyncProc = fn
  DSynchronize(false)
  threadSyncProc = nil
##
# 锁
initLock(syncLock)
##
#------------ global vars ----------------------
##
var
{{range $el := .InstanceObjects}}
  {{$el.Name}}* = As{{$el.Name}}({{$el.InstanceFunc}}())
{{end}}
